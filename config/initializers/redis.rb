configure do |app|
  redis = Redis.new(app.redis.symbolize_keys)
  redis_listener = Thread.new do |t|
    begin
      redis.subscribe(:pibi_realtime) do |on|
        on.subscribe do |channel, subscriptions|
          puts "Subscribed to ##{channel} (#{subscriptions} subscriptions)"
        end

        on.message do |channel, message|
          puts "##{channel}: #{message}"
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