module DST
  class Group < ::Sequel::Model(DST::DB)
    set_dataset :cchp_groups_base
    set_primary_key :group_id

    def_column_alias :id, :group_id
    def_column_alias :name, :group_name

    ########## associations ##########
    one_to_many :benefit_plans, :key => :group_id, :primary_key => :group_id
    one_to_many :disenroll_records, :key => :c_grp
    one_to_many :members, :key => :group_num
    one_to_many :enrollment_records, :key => :grp_id
    ##################################

    def cov_day
      super.to_date
    end

    def renewal_month
      cov_day.month
    end

    def is_exchange?
      DST.exchange_lobs.include?(lob)
    end

    def benefit_plan(params={})
      benefit_plans_dataset.record!(params)
    end

    dataset_module do
      def renewal_month(*months)
        # months = args.map{|m|Date.civil(1900,m.to_i,1).strftime('%b').upcase}
        # where(:open_month => months)
        where('month(cov_day) in ?', months)
      end
    end
  end
end