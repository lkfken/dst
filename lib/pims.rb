require 'sequel_connect'

module PIMS
  class Config
    class << self
      include SequelConnect
      def filename
        File.join(File.dirname(__FILE__), '..', 'config', 'pims_database.yml')
      end
      def stage
        ENV['PIM_DB_STAGE']
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