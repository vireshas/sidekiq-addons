$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('workers', __FILE__)
require 'coveralls'
Coveralls.wear!

require 'sidekiq'
Sidekiq.options[:redis_url] = {
  url: 'redis://127.0.0.1:6379/15'
}

require 'sidekiq/addons/util'
require 'sidekiq/addons'
require 'workers/worker'