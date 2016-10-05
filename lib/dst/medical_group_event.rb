module DST
  class MedicalGroupEvent < ::Sequel::Model(DST::DB)
    set_dataset :kt_mem_reg_hist_result

    def_column_alias :member_id, :mem_id

    ########## associations ##########

    many_to_one :member

    ##################################

    def medical_group
      case mem_region
      when 'SF', 'SM'
        'CCHCA'
      when 'HPMG'
        'Hill Physicians'
      when 'IHH'
        'Imperial'
      when 'CCHP'
        'CCHP'
      else
        raise "#{mem_region} not defined"
      end
    end
  end
end