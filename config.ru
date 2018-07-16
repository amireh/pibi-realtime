require 'rubygems'
require 'bundler/setup'
require 'yaml'
require_relative './lib/dispatcher'
require_relative './lib/faye_extensions/authentication'
require_relative './lib/faye_extensions/logging'

env_profile = ENV.fetch('RACK_ENV', 'development')

Bundler.require(:default, env_profile)

config_file = File.expand_path('../config/application.yml', __FILE__)

unless File.exists?(config_file)
  raise "Missing required config file: #{config_file}"
end

config = YAML.load_file(config_file)[env_profile]
redis  = Redis.new(config['redis'])

Faye::WebSocket.load_adapter('puma')
Faye::RackAdapter.new({
  mount: '/',
  timeout: config['faye']['timeout'],
  extensions: [
    FayeExtensions::Logging.new,
    FayeExtensions::Authentication.new(config),
  ],
  engine: {
    type: Faye::Redis,
    host: config['redis']['host'],
    port: config['redis']['port'],
    password: config['redis']['password'],
    namespace: config['redis']['namespace'],
    database: config['faye']['redis']['database'],
  }
}).tap do |faye|
  Faye.ensure_reactor_running!
  Dispatcher.new.start(config, faye.get_client)
  run faye
end
