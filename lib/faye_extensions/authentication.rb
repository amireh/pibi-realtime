module FayeExtensions
  class Authentication
    def initialize(config)
      @redis = Redis.new(config['redis'])
    end

    def incoming(message, request, callback)
      # Let non-subscribe messages through
      authenticate(message) if message['channel'] == '/meta/subscribe'

      # Call the server back now we're done
      callback.call(message)
    end

    private

    def authenticate(message)
      STDERR.puts "faye: client is subscribing, testing authenticity"
      STDERR.puts "faye: #{message}"

      # Get subscribed channel and auth token
      subscription = message['subscription']
      access_token = message['ext'] && message['ext']['accessToken']

      # Add an error if the tokens don't match
      if @redis.get(subscription) != access_token
        message['error'] = 'Invalid subscription auth token.'
      end
    rescue StandardError => e
      STDERR.puts "faye: internal error; unable to authenticate: #{e}"
    end
  end
end