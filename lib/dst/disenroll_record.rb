module DST
  class DisenrollRecord < ::Sequel::Model(::SequelConnect::DB)
    set_dataset :disenroll_base_view
    many_to_one :member

    dataset_module do
      def exclude_cancel_records
        exclude(:begin_cov => :disenr_dt)
      end

      # this one include cancel records.  Should considering using #eligibility_record_on instead
      def filter_by_date(date)
        filter { |record| (record.begin_cov <= date) & (record.disenr_dt >= date) }
      end
    end
  end
end