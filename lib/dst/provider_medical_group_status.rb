module DST
  class ProviderMedicalGroupStatus < ::Sequel::Model(DST::DB)
    set_dataset :prov_region_vendor_base_view
    set_primary_key [:provider_id, :lob, :prov_reg_eff_dt]

    ########## associations ##########

    many_to_one :physician, :class => :'DST::Physician',
                :key               => [:provider, :lob], :primary_key => [:provider_id, :lob]

    ##################################

    dataset_module do
      def span(params={})
        end_date = params.fetch(:end_date, Date.civil(2999, 12, 31))
        ds       = where('prov_reg_eff_dt <= ?', end_date)
        return ds if ds.empty?
        start_date    = params.fetch(:start_date, Date.civil(1900, 1, 1))
        ds_start_date = ds.exclude('prov_reg_eff_dt > ?', start_date).max(:prov_reg_eff_dt)
        ds_start_date.nil? ? ds : ds.where('prov_reg_eff_dt >= ?', ds_start_date)
      end

      def current_records
        from_self(:alias => :self).join_table(:inner,
                                              select_group(:provider___provider_id, :region___provider_region)
                                                  .select_append { max(:prov_reg_eff_dt).as(:prov_region_eff_dt) },
                                              :provider_id => :provider, :provider_region => :region) do |j, lj, js|
          Sequel.expr(Sequel.qualify(j, :prov_region_eff_dt) => Sequel.qualify(lj, :prov_reg_eff_dt))
        end.select_all(:self).from_self
      end
    end
  end
end