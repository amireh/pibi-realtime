#!/usr/bin/env ruby

$LOAD_PATH << File.join(File.dirname(__FILE__), '..')

require 'config/boot'

EM.run {
  client = Faye::Client.new(ARGV[2] || 'http://localhost:9123/')
  client.publish(ARGV[0], 'text' => "#{ARGV[1]}")

  puts "Publishing to #{ARGV[0]} -> #{ARGV[1]}"

  EM.add_timer(0.5) { EM.stop }
}