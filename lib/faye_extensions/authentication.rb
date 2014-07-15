class FayeExtensions::Authentication
  attr_reader :redis

  def initialize
    @redis = Redis.new(Sinatra::Application.redis.symbolize_keys)
  end

  def incoming(message, request, callback)
    puts "Extension Authentication is running: #{message}"
    puts "Request session: (#{request.session['id'] || request.session[:id]}) #{request.session}"

    # Let non-subscribe messages through
    if message['channel'] == '/meta/subscribe'
      # Get subscribed channel and auth token
      subscription = message['subscription']
      access_token = message['ext'] && message['ext']['accessToken']

      # Add an error if the tokens don't match
      if redis.get(subscription) != access_token
        message['error'] = 'Invalid subscription auth token.'
      end
    end

    # Call the server back now we're done
    callback.call(message)
  end
end