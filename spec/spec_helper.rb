$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'coveralls'
Coveralls.wear!

require 'sidekiq'
Sidekiq.options[:redis_url] = {
  url: 'redis://127.0.0.1:6379/15'
}

require 'sidekiq/addons/util'
require 'sidekiq/addons'

class MockWorker
  include Sidekiq::Worker

  def perform(arg)
  end
end

class IgnoreWorker
  include Sidekiq::Worker
  sidekiq_options :ignore_priority => true

  def perform(arg)
  end
end

class NonDefaultWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :non_default

  def perform(arg)
  end
end

class MinPriorityWorker
  include Sidekiq::Worker
  sidekiq_options :min_priority => 50

  def perform(arg)
  end
end

class LazyEvalWorker
  include Sidekiq::Worker
  sidekiq_options :lazy_eval => Proc.new { |param|
    param.first.to_i > 50
  }

  def perform(arg)
  end
end

