require "byebug"
require "sidekiq/addons/version"
require "sidekiq/addons/prioritize/enqr"
require "sidekiq/addons/prioritize/deqr"

module Sidekiq
  module Addons
    Sidekiq.configure_client do |config|
      config.client_middleware do |chain|
        chain.add Sidekiq::Addons::Prioritize::Enqr
        config.redis = { url: ENV['REDIS_URL'] || 'redis://127.0.0.1/0' }
      end
    end

    Sidekiq.configure_server do |config|
      Sidekiq.options[:fetch] = Sidekiq::Addons::Prioritize::Deqr
      config.redis = { url: ENV['REDIS_URL'] || 'redis://127.0.0.1/0' }
      config.client_middleware do |chain|
        chain.add Sidekiq::Addons::Prioritize::Enqr
        config.redis = { url: ENV['REDIS_URL'] || 'redis://127.0.0.1/0' }
      end
    end
  end
end
