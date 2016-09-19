$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'coveralls'
Coveralls.wear!

require 'sidekiq'
require 'sidekiq/addons/util'
require 'sidekiq/addons'
require 'workers'

Sidekiq::Addons.configure({
  :redis_url => { url: 'redis://127.0.0.1:6379/15'}
})
