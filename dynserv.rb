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

# allow conversion from Time to DateTime
class Time
  def to_datetime
    DateTime.new(year, month, day, hour, min, sec)
  rescue NameError
    nil
  end
end

get '/' do
  erb :index
end

# the javascript only needs the coordinates plus the opacity - we don't have to return the entire
# grid, since the javascript is responsible for initialization
get '/points' do
  point_array = []
  if params[:last_update]
    # TODO: this does not take into account the time zone
    # uses epochs, thanks to http://www.epochconverter.com/
    # we remove 10 seconds to cover server latency
    last_update = Time.at(params[:last_update].to_i - 10).to_datetime
    points = Point.all(:created_at.gt => last_update)
  else
    points = Point.all
  end
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
  # OPTIMIZE: much too frequent!
  Point.expire_points!
  "#{x}, #{y} saved."
end

get '/timestamp' do
  Point.first().created_at.to_s
end