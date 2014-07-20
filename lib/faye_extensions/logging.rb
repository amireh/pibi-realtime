class FayeExtensions::Logging
  def incoming(message, request, callback)
    if DEBUG
      puts "[in]  #{message['channel']} ~> #{message}"
    end

    callback.call(message)
  end

  def outgoing(message, callback)
    if DEBUG
      puts "[out] #{message['channel']} ~> #{message}"
    end

    callback.call(message)
  end
end