#!/usr/bin/ruby

require 'sinatra'
require 'json'
require 'redis'

redis = Redis.new

configure { set :server, :puma }

before do
  content_type :json
end

get '/' do
  redis.get('json')
end

post '/' do
  body = request.body.read
  redis.set('json', body)
end
