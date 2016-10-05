module DST
  class DisenrollRecord < ::Sequel::Model(DST::DB)
    set_dataset :disenroll_base_view

    def_column_alias :group_id, :c_grp
    def_column_alias :member_id, :mem_id
    def_column_alias :effective_date, :begin_cov
    def_column_alias :disenroll_date, :disenr_dt
    def_column_alias :disenroll_reason_id, :dis_reas

    ########## associations ##########

    many_to_one :member
    many_to_one :group
    many_to_one :reason, :class => :'DST::DisenrollReason', :key => :dis_reas

    ##################################

    dataset_module do
      def exclude_cancel_records
        exclude(:begin_cov => :disenr_dt)
      end

      def last_disenroll_records
        disenroll_records = DST::DisenrollRecord
                                .exclude_cancel_records
                                .select_group(:mem_id___member_id)
                                .select_append { max(:disenr_dt).as(:max_disenr_dt) }

        from_self(:alias => :self).join(disenroll_records, :max_disenr_dt => :disenr_dt, :member_id => :mem_id)
                                       .select_all(:self)
      end

      # this one include cancel records.  Should considering using #eligibility_record_on instead
      def on(date)
        filter { |record| (record.begin_cov <= date) & (record.disenr_dt >= date) }
      end
    end
  end
end