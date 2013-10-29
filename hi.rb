require 'rubygems'
require 'data_mapper' # requires all the gems listed above
require 'dm-sqlite-adapter' # requires all the gems listed above

# If you want the logs displayed you have to do this before the call to setup
DataMapper::Logger.new($stdout, :debug)

# An in-memory Sqlite3 connection:
DataMapper.setup(:default, 'sqlite::memory:')


class User
  include DataMapper::Resource

  property :id, Serial # An auto-increment integer key
  property :name, String # A varchar type string, for short strings
  property :password, String # A varchar type string, for short strings

  has n, :visits
end

class Visit
  include DataMapper::Resource

  property :id, Serial # An auto-increment integer key
  property :created_at, DateTime # A DateTime, for any date you might like.

  belongs_to :user
end

DataMapper.finalize


require 'dm-migrations'
DataMapper.auto_migrate!
#DataMapper.auto_upgrade!


require 'sinatra'
require "sinatra/reloader"

enable :sessions

get '/' do
  if session['user_name']
    user = User.first(:name => session['user_name'])
    if user
      erb :index, :locals => { :user => user }
    else
      "User with name \"#{session['user_name']}\" not found."
    end
  else
    redirect '/login'
  end
end

get '/login' do
  erb :login
end

post '/login' do
  user = User.first(:name => params[:name], :password => params[:password])
  if user
    visit = Visit.new(:created_at => Time.now)
    visit.save
    user.visits << visit
    user.save

    session['user_name'] = user.name
    redirect '/'
  else
    'Invalid credentials'
  end
end

get '/registration' do
  erb :registration
end

post '/registration' do
  if User.first(:name => params[:name])
    'User with such name already registered'
  else
    user = User.new(:name => params[:name], :password => params[:password])
    user.save
    session['user_name'] = user.name
    redirect '/'
  end
end
