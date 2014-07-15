#!/usr/bin/env ruby

require 'faye'

EM.run {
  client = Faye::Client.new('http://localhost:9123/')
  client.publish(ARGV[0], 'text' => "#{ARGV[1]}")

  puts "Publishing to #{ARGV[0]} -> #{ARGV[1]}"

  EM.add_timer(1) { EM.stop }
}