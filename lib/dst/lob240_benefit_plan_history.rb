module DST
  class Lob240BenefitPlanHistory < ::Sequel::Model(DST::DB)
    set_dataset :kt_him_cur_ben_plan_hist

    def_column_alias :name, :cur_ben_plan

    ########## associations ##########

    many_to_one :member

    ##################################

    ########## typecasting ##########

    def term_dt
      super.to_date
    end

    def eff_dt
      super.to_date
    end

    #################################

    dataset_module do
      def record(params={})
        date = params.fetch(:on) { raise KeyError, 'Missing :on => [date]' }
        where('eff_dt <= ?', date).reverse(:eff_dt)
      end

      def record!(params={})
        record(params).first
      end
    end
  end
end