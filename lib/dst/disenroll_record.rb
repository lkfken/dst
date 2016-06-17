module DST
  class DisenrollRecord < ::Sequel::Model(DST::DB)
    set_dataset :disenroll_base_view

    def_column_alias :group_id, :c_grp
    def_column_alias :member_id, :mem_id
    def_column_alias :effective_date, :begin_cov
    def_column_alias :disenroll_date, :disenr_dt

    ########## associations ##########

    many_to_one :member
    many_to_one :group

    ##################################

    dataset_module do
      def exclude_cancel_records
        exclude(:begin_cov => :disenr_dt)
      end

      # this one include cancel records.  Should considering using #eligibility_record_on instead
      def on(date)
        filter { |record| (record.begin_cov <= date) & (record.disenr_dt >= date) }
      end
    end
  end
end