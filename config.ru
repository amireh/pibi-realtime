require 'rubygems'
require 'bundler/setup'
require 'yaml'
require 'erb'
require_relative './lib/dispatcher'
require_relative './lib/faye_extensions/authentication'
require_relative './lib/faye_extensions/logging'

env_profile = ENV.fetch('RACK_ENV', 'development')

Bundler.require(:default, env_profile)

config_file = File.expand_path('../config/application.yml', __FILE__)

unless File.exists?(config_file)
  raise "Missing required config file: #{config_file}"
end

def read_config(filename)
  content = File.read(filename)
  templated = ERB.new(content).tap { |x| x.filename = filename }.result(binding)
  evaluated = YAML.safe_load(templated, [], [], true, filename)
end

config = read_config(config_file)

unless config.key?(env_profile)
  fail "missing configuration for environment \"#{env_profile}\""
end

config = config[env_profile]

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
