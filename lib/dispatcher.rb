require 'singleton'
require 'json'
require 'eventmachine'

class Dispatcher
  def start(config, faye)
    EM.defer do
      begin
        redis = Redis.new(config['redis'])
        redis.subscribe(config['channel']) do |on|
          on.subscribe do |channel, subscriptions|
            STDERR.puts "Subscribed to ##{channel} (#{subscriptions} subscriptions)"
          end

          on.message do |channel, message|
            STDERR.puts "Redis: ##{channel}: #{message}"

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

              STDERR.puts(stream.split("\n").map(&:strip).join("\n"))
            end
          end

          on.unsubscribe do |channel, subscriptions|
            puts "Unsubscribed from ##{channel} (#{subscriptions} subscriptions)"
          end
        end
      rescue Redis::BaseConnectionError => error
        STDERR.puts "pibi-realtime: Redis connection error, retrying in 1s (#{error})"
        sleep 1
        retry
      end
    end
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

    STDERR.puts "Notified user: #{user_id} in channel #{user_channel}"
  end
end