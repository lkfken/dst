require 'dotenv'

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

module DST
  SequelConnect.filename = File.join(File.dirname(__FILE__), '..', 'config', 'database.yml')
  DB                     = SequelConnect.DB

  extend self

  def cchp_lobs
    commercial_lobs.concat(exchange_lobs).concat(medicare_lobs).concat(ppo_lobs)
  end

  def off_exchange_ifp_lobs
    %w[200 220 230]
  end

  def off_exchange_group_lobs
    %w[100 110 130]
  end

  def commercial_lobs
    off_exchange_group_lobs.concat(off_exchange_ifp_lobs)
  end

  def exchange_lobs
    %w[140 240]
  end

  def medicare_lobs
    %w[250 253 256]
  end

  def ppo_lobs
    %w[130 230]
  end

  def tpa_lobs
    300..2000
  end

  def cchp_service_area_zip_codes
    { san_francisco: %w[94102 94103 94104 94105 94107 94108 94109 94110 94111 94112 94114 94115 94116 94117
       94118 94121 94122 94123 94124 94127 94129 94130 94131 94132 94133 94134 94158].concat(%w[94140 94119 94126]),
      san_mateo:     %w[94005 94010 94011 94014 94015 94016 94017 94018 94019 94030 94037 94038 94044 94066
       94080 94083 94128 94401 94402 94403 94404 94497] }
  end
end

require_relative 'dst/benefit_plan'
require_relative 'dst/disenroll_reason'
require_relative 'dst/disenroll_record'
require_relative 'dst/enrollment_record'
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
