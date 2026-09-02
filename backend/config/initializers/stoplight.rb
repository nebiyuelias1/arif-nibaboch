if Rails.env.test?
  data_store = Stoplight::DataStore::Memory.new
else
  redis = Redis.new(url: ENV["REDIS_URL"] || "redis://localhost:6379")
  data_store = Stoplight::DataStore::Redis.new(redis)
end

Stoplight.configure do |config|
  config.data_store = data_store
  config.notifiers += [ Stoplight::Notifier::Logger.new(Rails.logger) ]
end

Stoplight::Admin.set :host_authorization, { permitted_hosts: [ ENV["APP_DOMAIN"], "localhost" ].compact }
