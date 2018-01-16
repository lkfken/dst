module DST
  module MemberInstanceMethods
    module MedicalGroup
      def medical_group_name
        case mem_region
        when 'SF', 'SM'
          'CCHCA'
        when 'CCHP'
          'CCHP'
        when 'HPMG'
          'Hill Physicians'
        when 'IHH'
          'Imperial'
        when 'JADE'
          'JADE'
        else
          raise "Undefine #{mem_region} medical group"
        end
      end
    end
  end
end
