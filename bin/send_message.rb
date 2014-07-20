#!/usr/bin/env ruby

$LOAD_PATH << File.join(File.dirname(__FILE__), '..')

require 'config/boot'
require 'json'

EM.run {
  params = begin
    JSON.parse(ARGV[2])
  rescue
    ARGV[2]
  end

  client = Faye::Client.new(ARGV[3] || 'http://localhost:9123/')
  client.publish(ARGV[0], {
    code: ARGV[1],
    params: params
  })

  puts "Publishing to #{ARGV[0]} -> #{ARGV[1]}"

  EM.add_timer(0.5) { EM.stop }
}