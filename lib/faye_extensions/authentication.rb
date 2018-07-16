class FayeExtensions::Authentication
  attr_reader :redis

  def initialize
    @redis = Redis.new(config['redis'])
  end

  def incoming(message, request, callback)
    # Let non-subscribe messages through
    if message['channel'] == '/meta/subscribe'
      puts "Client is subscribing, testing authenticity." if DEBUG

      # Get subscribed channel and auth token
      subscription = message['subscription']
      access_token = message['ext'] && message['ext']['accessToken']

      # Add an error if the tokens don't match
      if redis.get(subscription) != access_token
        puts "\t[ERROR]: 401 client is not authorized." if DEBUG
        message['error'] = 'Invalid subscription auth token.'
      end
    end

    # Call the server back now we're done
    callback.call(message)
  end
end