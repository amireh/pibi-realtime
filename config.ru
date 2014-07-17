require 'rubygems'
require 'bundler'
require './config/boot'
require './config/initialize'

Faye::WebSocket.load_adapter('puma')

$faye = Faye::RackAdapter.new({
  mount: '/',
  timeout: config[:faye][:timeout],
  extensions: [ FayeExtensions::Authentication.new ],
  engine: {
    type: Faye::Redis,
    host: config[:redis][:host],
    port: config[:redis][:port],
    password: config[:redis][:password],
    namespace: config[:redis][:namespace],
    database: config[:faye][:redis][:database],
  }
})

run $faye