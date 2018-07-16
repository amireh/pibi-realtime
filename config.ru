require 'rubygems'
require 'bundler'
# require 'active_support'
# require 'active_support/core_ext'
require './config/boot'
require './config/initialize'

Thread.abort_on_exception = true

Faye::WebSocket.load_adapter('puma')

faye = Faye::RackAdapter.new({
  mount: '/',
  timeout: config['faye']['timeout'],
  extensions: [
    FayeExtensions::Logging.new,
    FayeExtensions::Authentication.new,
  ],
  engine: {
    type: Faye::Redis,
    host: config['redis']['host'],
    port: config['redis']['port'],
    password: config['redis']['password'],
    namespace: config['redis']['namespace'],
    database: config['faye']['redis']['database'],
  }
})

configure do |config|
  Dispatcher.instance.start(config['redis'], faye.get_client)

  at_exit do
    Dispatcher.instance.stop
  end
end

run faye