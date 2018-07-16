require 'singleton'

class Dispatcher
  include Singleton

  def start(redis_config, faye)
    redis = Redis.new(redis_config)

    @listener = Thread.new do |t|
      begin
        redis.subscribe(:pibi_realtime) do |on|
          on.subscribe do |channel, subscriptions|
            puts "Subscribed to ##{channel} (#{subscriptions} subscriptions)"
          end

          on.message do |channel, message|
            puts "Redis: ##{channel}: #{message}"# if DEBUG

            begin
              process_message(message, faye)
            rescue Exception => e
              stream = <<-ERROR
              ---------------------------------------------------------------
              WARN: Processing of Pibi command has failed:

              >   Payload:
              >   #{message}

              >   Error details:
              >   #{e.inspect}

              Command will be discarded.
              ---------------------------------------------------------------
              ERROR

              puts(stream.split("\n").map(&:strip).join("\n"))
            end
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
  end

  def stop
    return unless @listener.nil?

    @listener.kill
    @listener = nil
  end

  private

  def process_message(message, faye)
    params = JSON.parse(message)

    unless params.is_a?(Hash)
      raise ArgumentError.new("Unexpected command structure from Pibi.")
    end

    unless params.has_key?('user_id')
      raise ArgumentError.new("Command is missing the 'user_id' field.");
    end

    user_id = params['user_id']
    user_channel = "/channels/#{user_id}"

    faye.publish(user_channel, {
      code: params['code'],
      params: params['params'],
      client_id: params['client_id']
    })

    puts "Notified user: #{user_id} in channel #{user_channel}"# if DEBUG
  end
end