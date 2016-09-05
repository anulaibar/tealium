#!/usr/bin/ruby

require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require 'redis'

configure do
  set :server, :puma
  enable :cross_origin
end

redis = Redis.new

get '/' do
  content_type :json
  redis.get('json')
end

post '/' do
  body = request.body.read
  redis.set('json', body)
end
