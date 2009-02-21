require 'rubygems' unless defined? ::RubyGems
require 'sinatra' unless defined? ::Sinatra

require 'ruby-debug'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'json'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/dynserv.sqlite3")

# ******************************* MODELS
class Point
  include DataMapper::Resource
  
  property :id, Serial
  property :x, Integer
  property :y, Integer
  property :opacity, Integer, :default => 100
  property :created_at, DateTime
  
  # make points "age" by lowering their opacity, then eventually destroy them completely
  def self.expire_points!
    points = self.all
    points.each do |point|
      point.opacity -= 1
      if point.opacity <= 0
        point.destroy
      else
        point.save
      end
    end
  end
  
end

DataMapper.auto_upgrade!
# DataMapper.auto_migrate!

get '/' do
  erb :index
end

# the javascript only needs the coordinates plus the opacity - we don't have to return the entire
# grid, since the javascript is responsible for initialization
get '/points' do
  point_array = []
  points = Point.all
  points.each do |point|
    point_array << { :x => point.x, :y => point.y, :opacity => point.opacity }
  end
  JSON.generate(point_array)
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

get '/timestamp' do
  DateTime.now.to_s
end