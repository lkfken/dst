# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dst/version'
require 'rbconfig'

Gem::Specification.new do |gem|
  gem.name    = 'dst'
  gem.version = DST::VERSION
  gem.authors = ['Kenneth Leung']
  gem.email   = ['github@leungs.us']

  gem.summary     = %q{Database models written in Ruby Sequel}
  gem.description = %q{Database models written in Ruby Sequel}

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if gem.respond_to?(:metadata)
    gem.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  other_files        = ['.env']
  gem.files         = files.concat(other_files)
  gem.bindir        = "exe"
  gem.executables   = gem.files.grep(%r{^exe/}) { |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_dependency 'dotenv'
  gem.add_dependency 'sequel'
  gem.add_development_dependency 'sequel_connect', '>= 0.1.3'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'eed_db'
  gem.add_development_dependency 'eligibility'
  gem.add_development_dependency 'os'
  gem.add_development_dependency 'jdbc-jtds' if RbConfig::CONFIG['RUBY_INSTALL_NAME'] == 'jruby'
  gem.add_development_dependency 'jdbc-sqlite3' if RbConfig::CONFIG['RUBY_INSTALL_NAME'] == 'jruby'
  gem.add_development_dependency 'tiny_tds' if RbConfig::CONFIG['RUBY_INSTALL_NAME'] == 'ruby'
  gem.add_development_dependency 'dataset_exporter'
  gem.add_development_dependency 'awesome_print'
  gem.add_development_dependency 'terminal-table'
  gem.add_development_dependency 'httpclient'
  gem.add_development_dependency 'nokogiri'

  gem.require_paths = ['lib']


end