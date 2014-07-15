require 'lib/faye_extensions/authentication'

configure do |settings|
  Faye::WebSocket.load_adapter('puma')

  use Faye::RackAdapter, {
    mount: '/',
    timeout: settings.faye[:timeout],
    extensions: [ FayeExtensions::Authentication.new ],
    engine: {
      type: Faye::Redis,
      host: settings.faye[:engine][:host],
      port: settings.faye[:engine][:port],
      password: settings.faye[:engine][:password],
      database: settings.faye[:engine][:database],
      namespace: settings.faye[:engine][:namespace]
    }
  }

  if DEBUG
    puts "Faye mounted at '/'"
  end
end