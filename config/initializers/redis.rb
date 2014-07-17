configure do |config|
  redis = Redis.new(config[:redis].symbolize_keys)
  redis_listener = Thread.new do |t|
    begin
      redis.subscribe(:pibi_realtime) do |on|
        on.subscribe do |channel, subscriptions|
          puts "Subscribed to ##{channel} (#{subscriptions} subscriptions)"
        end

        on.message do |channel, message|
          puts "Redis: ##{channel}: #{message}" if DEBUG
          params = JSON.parse(message)
          user_channel = "/channels/#{params['user_id']}"

          $faye.get_client.publish(user_channel, {
            code: params['code'],
            params: params['params']
          })

          puts "Notified user: #{params['user_id']} in channel #{user_channel}" if DEBUG
        end

        on.unsubscribe do |channel, subscriptions|
          puts "Unsubscribed from ##{channel} (#{subscriptions} subscriptions)"
        end
      end
    rescue Redis::BaseConnectionError => error
      puts "Redis connection error: #{error}, retrying in 1s"
      sleep 1
      retry
    end
  end

  at_exit do
    redis_listener.kill
  end
end