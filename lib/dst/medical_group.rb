module DST
  class MedicalGroup < ::Sequel::Model(DST::DB)
    VALID_PCP_CAPACITY_CODE ||= %w[PPCP FPCP]

    set_dataset :prov_region_base_view
    set_primary_key [:provider_id, :lob, :prov_reg_eff_dt, :prov_capacity]

    ########## associations ##########

    many_to_one :physician, :class => :'DST::Physician',
                :key               => [:provider, :lob], :primary_key => [:provider_id, :lob]

    ##################################
    def value
      if %w[SM SF].include?(region)
        case prov_capacity
        when 'FPCP'
          'SM'
        when 'PPCP'
          'SF'
        end
      else
        region
      end
    end

    dataset_module do

      def span(params={})
        end_date = params.fetch(:end_date, Date.civil(2999, 12, 31))
        ds       = where('prov_reg_eff_dt <= ?', end_date)
        return ds if ds.empty?

        start_date    = params.fetch(:start_date, Date.civil(1900, 1, 1))
        ds_start_date = ds.exclude('prov_reg_eff_dt > ?', start_date).max(:prov_reg_eff_dt)
        ds_start_date.nil? ? ds : ds.where('prov_reg_eff_dt >= ?', ds_start_date)
      end

      def active
        where(:active_status => '1')
      end

      def pcp
        where(:prov_capacity => VALID_PCP_CAPACITY_CODE)
      end

      def eligible(params={})
        date = params.fetch(:on)
        span(:end_date => date)
      end

      def hpmg
        where(:region => 'HPMG')
      end

      def regions!
        select_group(:region).map(:region)
      end

    end
  end
end