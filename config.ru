require 'rubygems'
require 'sinatra'
 
set :environment,  :production
disable :run

require 'dynserv'

run Sinatra::Application