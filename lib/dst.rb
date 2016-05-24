require 'bundler'
Bundler.setup
require 'dotenv'
Dotenv.load!

require 'sequel_connect'
require_relative 'dst/member'
require_relative 'dst/physician'

module DST
end

