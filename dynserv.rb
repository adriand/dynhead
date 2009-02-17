require 'rubygems' unless defined? ::RubyGems
require 'sinatra' unless defined? ::Sinatra

require 'ruby-debug'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/dynserv.sqlite3")

# ******************************* MODELS
class Point
  include DataMapper::Resource
  
  property :id, Serial
  property :x, Integer
  property :y, Integer
  property :opacity, Integer, :default => 100
  property :created_at, DateTime
  
end

DataMapper.auto_upgrade!

# return the grid
get '/' do
  
end

post '/update' do
  x = params[:x]
  y = params[:y]
  point = Point.first(:x => x, :y => y)
  if point
    point.opacity = 100
  else
    point = Point.new(:x => x, :y => y)
  end
  point.save
  "#{x}, #{y} saved."
end