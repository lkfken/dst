require 'dotenv'
Dotenv.load!
require 'bundler/setup'
require 'sequel'
require 'sequel_connect'

require_relative 'dst/version'
require_relative 'dst/null_record'

module DST
  DB = SequelConnect::DB
  extend self
  def commercial_lobs
    %w[100 110 130 200 220 230]
  end

  def exchange_lobs
    %w[140 240]
  end

  def medicare_lobs
    %w[250 253 256]
  end
end

require_relative 'dst/benefit_plan'
require_relative 'dst/disenroll_record'
require_relative 'dst/group'
require_relative 'dst/lob240_benefit_plan_history'
require_relative 'dst/lob240_edi_enrollment'
require_relative 'dst/lob240_edi_reporting_category'
require_relative 'dst/lob240_edi_benefit'
require_relative 'dst/member'
require_relative 'dst/physician'
require_relative 'dst/medical_group'
require_relative 'dst/medicare_event'
require_relative 'dst/enrollment_record'