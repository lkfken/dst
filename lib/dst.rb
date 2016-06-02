require 'dotenv'
Dotenv.load!
require 'bundler'
Bundler.require

require_relative 'dst/null_record'

require_relative 'dst/disenroll_record'
require_relative 'dst/group'
require_relative 'dst/lob240_benefit_plan_history'
require_relative 'dst/member'
require_relative 'dst/physician'

module DST
  COMMERCIAL_LOBS = %w[100 110 130 200 220 230]
  EXCHANGE_LOBS   = %w[140 240]
  MEDICARE_LOBS   = %w[250 253 256]
end

