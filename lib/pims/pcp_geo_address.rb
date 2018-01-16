module PIMS
  class PCPGeoAddress < PIMS_Model
    set_dataset Sequel.qualify(SCHEMA, :pims_pv_active_geoaddress_results)

    dataset_module do
      def open_to_new_patients
        # solution 1
        a = [:'open to new patients', nil]
        b = [:'open to new patients', %w[Open]]
        where(Sequel.or([a, b]))
      end

      alias_method :accept_new_patients, :open_to_new_patients
      alias_method :open_panel, :open_to_new_patients

      def closed_panel
        where(:'open to new patients' => 'Closed')
      end

      def pcp
        where(:provider_type => %w[DUAL PCP])
      end

      def senior_medical_groups
        where(:cchp_region => %w[CCHP IHH JADE])
      end

      def cca_medical_groups
        where(:cchp_region => %w[CCHP JADE HPMG])
      end

      def ccsb_medical_groups
        where(:cchp_region => %w[CCHP JADE HPMG]).exclude(npi_key: PCPInfo.one_medical_group.select_group(:npi_key))
      end

      def off_exchange_medical_groups
        where(:cchp_region => %w[CCHP JADE HPMG])
      end
    end
  end
end