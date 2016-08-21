$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sidekiq'
Sidekiq.options[:redis_url] = {
  url: 'redis://127.0.0.1:6379/15'
}

require 'sidekiq/addons'

class MockWorker
  include Sidekiq::Worker

  def perform(arg)
  end
end

class MockWorkerFixedPrio
  include Sidekiq::Worker

  def perform(arg)
  end
end
