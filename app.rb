require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/flash'
require_relative './lib/peep'
require_relative './lib/user'
require './database_connection_setup.rb'

class Chitter < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    erb :homepage
  end

  get '/peeps' do
    # Fetch the user from the database, using an ID stored in the session
    @user = User.find(id: session[:user_id])
    @peeps = Peep.all
    erb :'peeps/show'
  end

  get '/peeps/new' do
    redirect '/peeps' unless session[:user_id]
    erb :'peeps/index'
  end

  post '/peeps' do
    Peep.create(text: params[:text], user_id: session[:user_id])
    redirect '/peeps'
  end

  get '/users/new' do
    erb :'users/new'
  end
  
  post '/users' do
    user = User.create(username: params[:username], email: params[:email], password: params[:password])
    redirect '/users/new' unless user
    # session[:user_id] = user.id
    redirect '/sessions/new'
  end

  get '/sessions/new' do
    # redirect '/peeps' if session[:user_id]
    erb :'sessions/new'
  end

  post '/sessions' do
    user = User.authenticate(email: params[:email], password: params[:password])
    if user
      session[:user_id] = user.id
      redirect '/peeps'
    else
      flash[:notice] = "Please check your email or password."
      redirect('/sessions/new')
    end
  end

  post '/sessions/destroy' do
    session.clear
    flash[:notice] = "You have signed out."
    redirect '/'
  end

  run! if app_file == $0
end
