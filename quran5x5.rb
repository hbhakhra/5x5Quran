require 'rubygems'  
require 'sinatra'  
require 'data_mapper'  
require 'json'
require 'dm-serializer'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/app-dev")

class User
  include DataMapper::Resource
  property :id, Serial
  property :fname, Text, :required => true
  property :lname, Text, :required => true
  property :email, Text, :required => true
  property :created_at, DateTime
  has n, :streaks
end

class Streak
	include DataMapper::Resource
	property :id, Serial
	property :start, DateTime, :required => true, :default => Time.now
	property :end, DateTime
	belongs_to :user
end

DataMapper.finalize.auto_upgrade!

get '/users' do
	@users = User.all :order => :id.desc
	@title = 'All Users'
	erb :users
end

get '/user/:id' do
  user = User.get params[:id]
  user.to_json(:methods => [:streaks])
end

post '/user' do  
  user = User.new  
  user.fname = params[:fname] 
  user.lname = params[:lname] 
  user.email = params[:email]
  user.created_at = Time.now  
  user.streaks << Streak.create
  user.save  
  redirect '/users'  
end  

put '/:userId/resetStreak' do
  user = User.get params[:userId]
  newest = user.streaks.last(:user => user)
  newest.end = Time.now
  newest.save
  user.streaks << Streak.create
  user.save
  redirect '/users'
end








