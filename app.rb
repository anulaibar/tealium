#!/usr/bin/ruby

require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require 'redis'

configure do
  set :server, :puma
  enable :cross_origin
end

before do
  content_type :json, charset: 'utf-8'
end

redis = Redis.new

get '/' do
  {endpoints: [
    "#{request.base_url}/dev",
    "#{request.base_url}/qa",
    "#{request.base_url}/dev/flush",
    "#{request.base_url}/qa/flush"
  ]}.to_json
end

get '/dev' do
  redis.get('dev')
end

get '/qa' do
  redis.get('qa')
end

get '/dev/flush' do
  redis.set('dev', '[]')
  {message: 'Deleted dev requests.'}.to_json
end

get '/qa/flush' do
  redis.set('qa', '[]')
  {message: 'Deleted QA requests.'}.to_json
end

post '/dev' do
  # handle åäö
  param = request.params['data'].force_encoding("ISO-8859-1").encode("UTF-8")
  data = JSON.parse(param)['data']
  json = JSON.parse(redis.get('dev'))
  json.unshift(data)
  redis.set('dev', json.to_json)
end

post '/qa' do
  # handle åäö
  param = request.params['data'].force_encoding("ISO-8859-1").encode("UTF-8")
  data = JSON.parse(param)['data']
  json = JSON.parse(redis.get('qa'))
  json.unshift(data)
  redis.set('qa', json.to_json)
end
