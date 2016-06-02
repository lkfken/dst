module DST
  class BenefitPlan < ::Sequel::Model(::SequelConnect::DB)
    set_dataset :cchp_grp_rid_hist_details_base

    ########## associations ##########

    many_to_one :group

    ##################################

    def_column_alias :name, :benefit_plan

    dataset_module do
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

