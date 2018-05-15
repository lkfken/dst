# coding: utf-8

require 'dotenv'
require 'yaml'

if File.exist?(gem_env_file = File.join(File.dirname(__FILE__), '..', '.env'))
  Dotenv.load!(gem_env_file)
else
  Dotenv.load!
end

require 'bundler/setup'
require 'sequel'
require 'sequel_connect'

require_relative 'dst/version'
require_relative 'dst/null_record'
require_relative 'pims'
module DST
  class Config
    class << self
      include SequelConnect

      def filename
        File.join(File.dirname(__FILE__), '..', 'config', 'database.yml')
      end

      def stage
        ENV['DST_DB_STAGE']
      end

    end
  end
  DB                                = DST::Config.DB
  Sequel::Model.require_valid_table = false
  Sequel.split_symbols              = true
  DB.extension :auto_literal_strings
  SCHEMA = Sequel.qualify(:dst, :dbo)
  # a convenient way to make instance methods into class methods
  # ie: DST.cchp_lobs
  extend self

  def on_exchange_lobs
    %w[140 240]
  end

  alias_method :exchange_lobs, :on_exchange_lobs
  alias_method :on_exchange_hmo_lobs, :on_exchange_lobs

  def ppo_lobs
    %w[130 230]
  end

  def employer_sponsored_lobs
    %w[100 110 130 140]
  end

  def ifp_lobs
    %w[200 220 230 240]
  end

  def medicare_lobs
    %w[250 253 256]
  end

  def tpa_lobs
    300..2000
  end

  def cchp_lobs
    employer_sponsored_lobs | ifp_lobs | medicare_lobs
  end

  def hmo_lobs
    cchp_lobs - ppo_lobs
  end

  def off_exchange_lobs
    cchp_lobs - exchange_lobs
  end

  def off_exchange_commercial_lobs
    off_exchange_lobs - medicare_lobs
  end

  def off_exchange_commercial_hmo_lobs
    off_exchange_commercial_lobs & hmo_lobs
  end

  def off_exchange_ifp_lobs
    off_exchange_lobs & ifp_lobs
  end

  def off_exchange_hmo_lobs
    off_exchange_lobs & hmo_lobs
  end

  def off_exchange_ifp_hmo_lobs
    off_exchange_ifp_lobs & off_exchange_hmo_lobs
  end

  def off_exchange_group_lobs
    off_exchange_lobs & employer_sponsored_lobs
  end

  def off_exchange_group_hmo_lobs
    off_exchange_group_lobs & hmo_lobs
  end

  def cchp_service_area_zip_codes
    { san_francisco: %w[94102 94103 94104 94105 94107 94108 94109 94110 94111 94112 94114 94115 94116 94117 94118
                        94121 94122 94123 94124 94127 94128 94129 94130 94131 94132 94133 94134 94158],
      san_mateo:     %w[94005 94010 94011 94014 94015 94016 94017 94018 94019 94030 94037 94038 94044 94066 94080
                        94083 94401 94402 94403 94404 94497] }
  end
end

require_relative 'dst/benefit_plan'
require_relative 'dst/disenroll_reason'
require_relative 'dst/disenroll_record'
require_relative 'dst/enrollment_record'
require_relative 'dst/exceptions'
require_relative 'dst/group'
require_relative 'dst/lob240_benefit_plan_history'
require_relative 'dst/lob240_edi_enrollment'
require_relative 'dst/lob240_edi_reporting_category'
require_relative 'dst/lob240_edi_benefit'
require_relative 'dst/lob240_grace_period_letter'
require_relative 'dst/medical_group'
require_relative 'dst/medical_group_event'
require_relative 'dst/medicare_event'
require_relative 'dst/member'
require_relative 'dst/physician'
require_relative 'dst/subscriber'
require_relative 'dst/provider_medical_group_status'
require_relative 'dst/other_insurance'
require_relative 'dst/insurance_company'
require_relative 'dst/claim_base_record'
require_relative 'dst/data_refresh_tracker'
require_relative 'dst/ped_record'
