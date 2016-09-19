# Sidekiq::Addons

[![Join the chat at https://gitter.im/vireshas/sidekiq-addons](https://badges.gitter.im/vireshas/sidekiq-addons.svg)](https://gitter.im/vireshas/sidekiq-addons?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/vireshas/sidekiq-addons.svg?branch=master)](https://travis-ci.org/vireshas/sidekiq-addons)
[![Coverage Status](https://coveralls.io/repos/github/vireshas/sidekiq-addons/badge.svg?branch=master)](https://coveralls.io/github/vireshas/sidekiq-addons?branch=master)
[![Gem Version](https://badge.fury.io/rb/sidekiq-addons.svg)](https://badge.fury.io/rb/sidekiq-addons)


  * Dynamically change job priority with in the same queue.  
 
## Overview
  
Enqueue job with default priority
```ruby
  MockWorker.perform_async(1)
```
Enqueue job with a priority
```ruby
 job1 = MockWorker.perform_async(1, {:with_priority => 80})
 job2 = MockWorker.perform_async(1, {:with_priority => 90})
 job3 = MockWorker.perform_async(1, {:with_priority => 100})
 job4 = MockWorker.perform_async(1, {:with_priority => 70})
```
When jobs are enqueued in this order, this gems makes sure that, job3 is the one that will be executed next(as it has the highest priority), this will be followed by job2, job1 and job4.

## Usage

Call `Sidekiq::Addons.configure()` from your stack initialize Sidekiq::Addons.  

Use different redis:  
  Sidekiq::Addons.configure({
    url: 'redis://127.0.0.1/2',
  })


To always use default priority set ignore_priority => true at worker level
```ruby
class IgnoreWorker
  include Sidekiq::Worker
  sidekiq_options :ignore_priority => true

  def perform(arg)
  end
end
```

Moves job to priority queue when with_priority or blocks value is greater than min_priority
```ruby
class MinPriorityWorker
  include Sidekiq::Worker
  sidekiq_options :min_priority => 50

  def perform(arg)
  end
end
```

Use a block to assign priority dynamically
```ruby
class LazyEvalWorker
  include Sidekiq::Worker
  sidekiq_options :lazy_eval => Proc.new { |param|
    param.first.to_i > 50
  }

  def perform(arg)
  end
end
```
Proc should either return a number or true to use priority scheduling


## Benefits  
  * Doesnt interrupt those jobs that are already getting executed, but, makes sure that the next job that will be executed will be a highest priority job.   
  * Minimal code changes: You just have to pass an extra param when you enqueue a job and jobs will be scheduled based on this param value.
  * Minimal network transfer: loads a script in Redis and uses SHA to execute it. This greatly reduces network data transfer.
  * Can talk to remote Redis: From your stack, you can pass a REDIS_URL in Sidekiq.options and it can talk to that Redis.
  * When Sidekiq is interruppted, active jobs are re-enqueued with the existing priority. When Sidekiq boots-up, it will still pick the highest prortized job.
  * Has automic ZPOP

## Coming up
  * Uniqueness: removes duplicate jobs
  * Cron(?)
  * Stats
  * Monitor
  * Sidekiq-UI: integrate with sidekiq-UI
  * 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq-addons'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sidekiq-addons


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vireshas/sidekiq-addons.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
