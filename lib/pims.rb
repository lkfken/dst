require 'sequel_connect'

module PIMS
  class Config
    class << self
      include SequelConnect
      def filename
        default_config = File.join(File.dirname(__FILE__), '..', 'config', 'pims_database.yml')
        raise "#{default_config} is missing" unless File.exist?(default_config)
        local_config = File.join('.', 'config', 'pims_database.yml')
        if File.exist?(local_config)
          warn "Using local database.yml (#{local_config})"
          local_config
        else
          default_config
        end
      end
    end
  end
  Sequel::Model.require_valid_table = false
  PIMS_Model = Class.new(Sequel::Model)
  PIMS_Model.def_Model(self)

  DB = PIMS::Config.DB
  SCHEMA = Sequel.qualify(:cchp_medical_management, :dbo)
end

require_relative 'pims/pcp_geo_address'
require_relative 'pims/pcp_info'