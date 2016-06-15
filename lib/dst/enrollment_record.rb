module DST
  class EnrollmentRecord < ::Sequel::Model(DST::DB)
    set_dataset :wd_enrollment_base_view
    def_column_alias :member_id, :mem_id
    def_column_alias :id, :mem_id
    def_column_alias :group_id, :grp_id
    def_column_alias :mem_lob, :orig_lob_id
    many_to_one :member
    many_to_one :group

    dataset_module do
      def exclude_cancel_records
        exclude(:elig_eff_dt => :elig_exp_dt)
      end
      def eligible_on(params={})
        year = params.fetch(:year)
        month = params.fetch(:month)
        day = params.fetch(:day, 1)
        date = Date.civil(year, month, day)
        exclude_cancel_records.where('elig_eff_dt < ? and elig_exp_dt >= ?', date.next_month, date)
      end
    end

  end
end