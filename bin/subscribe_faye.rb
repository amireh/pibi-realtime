require 'faye'

EM.run {
  client = Faye::Client.new('http://localhost:9123/')

  client.subscribe('/foo') do |message|
    puts message.inspect
  end

  puts "Subscribed to channel '/foo'"

  client.publish('/foo', 'text' => 'Hello world')
  puts "Publishing to /foo"
}