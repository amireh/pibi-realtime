$ROOT = File.expand_path( File.join( File.dirname(__FILE__), '..' ) )
$LOAD_PATH << File.join( File.dirname(__FILE__), '..' )

require 'rubygems'
require 'bundler/setup'

ENV['RACK_ENV'] ||= 'development'

Bundler.require(:default, ENV['RACK_ENV'])

def config
  @config ||= begin
    filepath = File.join($ROOT, 'config', 'application.yml')

    unless File.exists?(filepath)
      raise "Missing required config file: #{filepath}"
    end

    YAML.load_file(filepath)[ENV['RACK_ENV']]
  end
end

def configure(&block)
  yield config
end

# -------------------
# Environment options
# -------------------

# DEBUG
#
# Controls logging of workers and modules.
DEBUG = !!ENV['DEBUG']