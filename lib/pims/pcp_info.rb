module PIMS
  class PCPInfo < PIMS_Model
    set_dataset :'PIMS_IndPV - Practice Info'

    dataset_module do
      def one_medical_group
        where(:pracname => 'One Medical Group')
      end
      def npi(n)
        where(:npi_key => n)
      end
    end
  end
end