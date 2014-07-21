#!/usr/bin/env ruby

$LOAD_PATH << File.join(File.dirname(__FILE__), '..')

require 'config/boot'

redis = Redis.new(config[:redis])

trap(:INT) { puts; exit }

begin
  puts "Publishing command: #{ARGV[0]}"
  redis.publish(config[:channel], ARGV[0])
rescue Redis::BaseConnectionError => error
  puts "#{error}, retrying in 1s"
  sleep 1
  retry
end