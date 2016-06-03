# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dst/version'

Gem::Specification.new do |gem|
  gem.name          = 'dst'
  gem.version       = DST::VERSION
  gem.authors       = ['Kenneth Leung']
  gem.email         = ['github@leungs.us']

  gem.summary       = %q{Database models written in Ruby Sequel}
  gem.description   = %q{Database models written in Ruby Sequel}

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if gem.respond_to?(:metadata)
    gem.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  gem.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  gem.bindir        = "exe"
  gem.executables   = gem.files.grep(%r{^exe/}) { |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_dependency 'sequel_connect'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'dotenv'
  gem.add_development_dependency 'jdbc-jtds'
  gem.add_development_dependency 'dataset_exporter'

  gem.require_paths = ['lib']


end