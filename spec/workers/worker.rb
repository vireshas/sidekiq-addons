require 'sidekiq/addons'

class MockWorker
  include Sidekiq::Worker

  def perform(*args)
  	puts args
  end
end

class IgnoreWorker
  include Sidekiq::Worker
  sidekiq_options :ignore_priority => true

  def perform(name , args)
  	puts args
  end
end

class NonDefaultWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :non_default

  def perform(*args)
  	puts args
  end
end

class MinPriorityWorker
  include Sidekiq::Worker
  sidekiq_options :min_priority => 50

  def perform(*args)
  	puts args
  end
end

class LazyEvalWorker
  include Sidekiq::Worker
  sidekiq_options :lazy_eval => Proc.new { |param|
    param.first.to_i > 50
  }

  def perform(*args)
  	puts args
  end
end
