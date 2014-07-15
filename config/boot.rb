$ROOT = File.expand_path( File.join( File.dirname(__FILE__), '..' ) )
$LOAD_PATH << File.join( File.dirname(__FILE__), '..' )

require 'rubygems'
require 'bundler/setup'

Bundler.require(:default, ENV['RACK_ENV'])

# -------------------
# Environment options
# -------------------

# DEBUG
#
# Controls logging of workers and modules.
DEBUG = !!ENV['DEBUG']

configure do |app|
  # register Sinatra::Contrib

  puts ">> Configuring"
  puts ">> Root: #{$ROOT}"
  puts ">> Environment: #{settings.environment}"

  rack_env = ENV['RACK_ENV']

  %w[faye redis].each { |cf|
    fp = File.join($ROOT, 'config', "%s.yml" %[cf] )

    unless File.exists?(fp)
      raise "Missing required config file: config/%s.yml" %[cf]
    end

    YAML.load_file(fp).with_indifferent_access[rack_env].tap do |config|
      config.keys.each do |key|
        settings.set key, config[key]
      end
    end
  }

  Dir.glob('lib/*.rb').each { |script| require(script) }

  set :server, :puma

  require "config/initializers/redis"
  require "config/initializers/faye"
end
