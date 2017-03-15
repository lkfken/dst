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
      def active
        group_id = association_join(:members).select_group(:group_id).exclude(:group_id => '')
        where(:group_id => group_id)
      end

      def not_active
        exclude(:group_id => active.select(:group_id))
      end
      def renewal_month(*months)
        # months = args.map{|m|Date.civil(1900,m.to_i,1).strftime('%b').upcase}
        # where(:open_month => months)
        where('month(cov_day) in ?', months)
      end

      def append_parent_gid
        g_groups   = Sequel.&(Sequel.function(:left, :group_id, 1) => 'G', :lob => %w[100 110])
        s_groups   = Sequel.&(Sequel.function(:left, :group_id, 1) => 'S', :lob => %w[100 110])
        parent_gid = Sequel.case([[g_groups, Sequel.function(:left, :group_id, 4)], [s_groups, Sequel.function(:left, :group_id, 5)]], :group_id)
        select_append(parent_gid.as(:parent_gid)).from_self
      end
    end
  end
end