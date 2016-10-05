module DST
  class Lob240GracePeriodLetter < ::Sequel::Model(DST::DB)
    set_dataset :kt_grace_period_letter
    many_to_one :subscriber
    set_primary_key :id
    dataset_module do
      def active
        where(:reactivation_date => nil).where(:disenroll_date => nil)
      end
    end
  end
end