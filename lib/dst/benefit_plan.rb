module DST
  class BenefitPlan < ::Sequel::Model(DST::DB)
    set_dataset :cchp_grp_rid_hist_details_base

    def_column_alias :name, :benefit_plan

    ########## associations ##########

    many_to_one :group

    ##################################

    dataset_module do
      def current_benefit_plans
        benefit_plans = DST::BenefitPlan
                            .select_group(:group_id)
                            .select_append { max(:eff_dates).as(:max_eff_dates) }

        from_self(:alias => :self).join(benefit_plans, { :max_eff_dates => :eff_dates, :group_id => :self__group_id })
            .select_all(:self)
      end

      def record(params={})
        date = params.fetch(:on) { raise KeyError, 'Missing :on => [date]' }
        where('eff_dates <= ?', date).reverse(:eff_dates)
      end

      def record!(params={})
        record(params).first
      end
    end
  end
end

