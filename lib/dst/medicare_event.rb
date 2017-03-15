module DST
  class MedicareEvent < ::Sequel::Model(DST::DB)
    set_dataset :mr_members_base_view

    def_column_alias :member_id, :memb_id
    def_column_alias :hicn, :hic_no

    ########## associations ##########

    many_to_one :member

    ##################################
    dataset_module do
      def current_lisc_date(date: Date.today)
        where('li_cpy_dt <= ?', date)
            .select_group(:memb_id___lisc_member_id)
            .select_append { max(:li_cpy_dt).as(:max_li_cpy_dt) }
        # .where('li_cpy_dt > ? and li_cpy_dt <= ?', Date.civil(1970, 1, 1), date)
      end

      def current_lisl_date(date: Date.today)
        where('li_sub_dt <= ?', date)
            .select_group(:memb_id___lisl_member_id)
            .select_append { max(:li_sub_dt).as(:max_li_sub_dt) }
        # .where('li_sub_dt > ? and li_sub_dt <= ?', Date.civil(1970, 1, 1), date)
      end

      def current_lis_seq_num(date: Date.today)
        from_self(:alias => :m)
            .join(current_lisc_date(date: date), { :lisc_member_id => :m__memb_id, :max_li_cpy_dt => :m__li_cpy_dt }, :table_alias => :lisc)
            .join(current_lisl_date(date: date), { :lisl_member_id => :m__memb_id, :max_li_sub_dt => :m__li_sub_dt }, :table_alias => :lisl)
            .group(:m__memb_id, :m__li_cpy_dt, :m__li_sub_dt, :m__li_cpy_ind, :m__li_sub_ind)
            .select(:memb_id___current_lis_memb_id).select_append { min(:seq_num).as(:current_lis_seq_num) }
      end

      def current_lis_event(params={})
        from_self(:alias => :m)
            .join(current_lis_seq_num(params), { :seq__current_lis_memb_id => :m__memb_id, :seq__current_lis_seq_num => :m__seq_num }, :table_alias => :seq)
            .select_all(:m)
      end
    end
  end
end