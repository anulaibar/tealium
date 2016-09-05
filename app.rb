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

get '/flush' do
  content_type :json
  redis.set('json', '{}')
  {message: 'Request log flushed.'}.to_json
end

post '/' do
  # handle åäö
  param = request.params['data'].force_encoding("ISO-8859-1").encode("UTF-8")
  data = JSON.parse(param)
  json = JSON.parse(redis.get('json'))
  key = Time.now.strftime "%Y-%m-%d %H:%M:%S"
  json[key] = data['data']
  redis.set('json', json.to_json)
end
