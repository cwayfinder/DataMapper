$LOAD_PATH.unshift File.expand_path('../', __FILE__)

require 'rubygems'

require 'data_mapper' # requires all the gems listed above
require 'dm-sqlite-adapter' # requires all the gems listed above
require 'dm-migrations'

require 'models/user'
require 'models/visit'


DataMapper::Logger.new($stdout, :debug)    # If you want the logs displayed you have to do this before the call to setup
DataMapper.setup(:default, 'sqlite::memory:')    # An in-memory Sqlite3 connection:
DataMapper.finalize
DataMapper.auto_migrate!
#DataMapper.auto_upgrade!


require 'sinatra'
require 'sinatra/base'
require "sinatra/reloader"
require 'sinatra/flash'

enable :sessions

module Utils
  def create_visit(user)
    user.visits.new(:created_at => Time.now)
    user.save

    session['user_name'] = user.name
    redirect '/'
  end
end

class LoginScreen < Sinatra::Base
  enable :sessions
  register Sinatra::Flash
  include Utils

  get('/login') { erb :login }

  post '/login' do
    user = User.first(:name => params[:name], :password => params[:password])
    if user
      create_visit(user)
    else
      flash[:error] = 'Invalid credentials'
      redirect '/login'
    end
  end
end

class RegistrationScreen < Sinatra::Base
  enable :sessions
  register Sinatra::Flash
  include Utils

  get('/registration') { erb :registration }

  post '/registration' do
    if User.first(:name => params[:name])
      flash[:error] = 'User with such name already registered'
      redirect '/registration'
    else
      user = User.new(:name => params[:name], :password => params[:password])
      create_visit(user)
    end
  end
end

class MyApp < Sinatra::Base
# middleware will run before filters
  use LoginScreen
  use RegistrationScreen

  get '/' do
    if session['user_name']
      user = User.first(:name => session['user_name'])
      if user
        erb :index, :locals => { :user => user }
      else
        "Some kind of shit has happened. User with name \"#{session['user_name']}\" not found."
      end
    else
      redirect '/login'
    end
  end

  get '/logout' do
    session.delete(:user_name)
    redirect '/login'
  end
end