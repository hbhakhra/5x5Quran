require 'rubygems'  
require 'sinatra'  
require 'data_mapper'  
require 'json'
require 'dm-serializer'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/app-dev")

class User 
  include DataMapper::Resource  
  property :id, Serial  
  property :fname, String 
  property :lname, String
  property :email, String, :required => true
  property :created_at, DateTime, :default => Time.now
end  
  
DataMapper.finalize.auto_upgrade!  

get '/' do
	User.all.to_a.to_json
end

get '/users' do
	@users = User.all :order => :id.desc
	@title = 'All Users'
	erb :users
end

post '/user' do
	user = User.new
	user.fname = params[:fname]
	user.lname = params[:lname]
	user.email = params[:email]
	user.save
	redirect '/users'
end

delete '/:id' do
	user = User.get params[:id]
	user.destroy
end

delete '/clear' do 
	User.destroy
end