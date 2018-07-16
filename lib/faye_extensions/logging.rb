module FayeExtensions
  class Logging
    def incoming(message, request, callback)
      STDERR.puts "faye: [in] #{clear_message(message)}" if ENV['DEBUG'] == '1'

      callback.call(message)
    end

    def outgoing(message, callback)
      STDERR.puts "faye: [out] #{clear_message(message)}" if ENV['DEBUG'] == '1'

      callback.call(message)
    end

    private

    def clear_message(msg)
      msg.clone.tap { |x| x['ext'] = 'NOT_LOGGING_PARAMETER' }
    end
  end
end
