require 'bundler'
Bundler.require(:default)
require 'dotenv'
Dotenv.load!

require 'sequel_connect'
require_relative 'dst/disenroll_record'
require_relative 'dst/group'
require_relative 'dst/lob240_benefit_plan_history'
require_relative 'dst/member'
require_relative 'dst/physician'

module DST
end

