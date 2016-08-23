# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq/addons/version'

Gem::Specification.new do |spec|
  spec.name          = "sidekiq-addons"
  spec.version       = Sidekiq::Addons::VERSION
  spec.authors       = ["Viresh S"]
  spec.email         = ["asviresh@gmail.com"]

  spec.summary       = %q{ Prioritize jobs in a queue, Uniqueness in jobs and Sidekiq based cron.}
  spec.description   = %q{ Prioritize jobs in a queue, Uniqueness in jobs and Sidekiq based cron.}
  spec.homepage      = "https://github.com/vireshas/sidekiq-addons"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|pkg)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "sidekiq", "~> 3.2"
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
