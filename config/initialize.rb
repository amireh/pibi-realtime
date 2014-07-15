configure do |app|
  puts ">> Configuring"
  puts ">> Root: #{$ROOT}"
  puts ">> Environment: #{ENV['RACK_ENV']}"

  require 'lib/faye_extensions'
  require "config/initializers/redis"
end
