require "byebug"
require "sidekiq"
require "sidekiq/addons/util"
require "sidekiq/addons/version"
require "sidekiq/addons/prioritize/enqr"
require "sidekiq/addons/prioritize/deqr"

module Sidekiq
  module Addons

    #set redis_url to default redis setttings if its not passed
    unless Sidekiq.options[:redis_url]
      Sidekiq.options[:redis_url] = {
        url: 'redis://127.0.0.1:6379/0'
      }
    end

    Sidekiq.configure_client do |config|
      config.client_middleware do |chain|
        chain.add Sidekiq::Addons::Prioritize::Enqr
        config.redis = Sidekiq.options[:redis_url]
      end
    end

    Sidekiq.configure_server do |config|
      Sidekiq.options[:fetch] = Sidekiq::Addons::Prioritize::Deqr
      config.redis = Sidekiq.options[:redis_url]
      config.client_middleware do |chain|
        chain.add Sidekiq::Addons::Prioritize::Enqr
        config.redis = Sidekiq.options[:redis_url]
      end
    end

  end
end
