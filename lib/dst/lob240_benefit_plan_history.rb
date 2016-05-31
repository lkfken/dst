module DST
  class Lob240BenefitPlanHistory < ::Sequel::Model(::SequelConnect::DB)
    set_dataset :kt_him_cur_ben_plan_hist

    def_column_alias :name, :cur_ben_plan

    many_to_one :member

    def eff_dt
      super.to_date
    end

    alias_method :eff_date, :eff_dt

    def term_dt
      super.to_date
    end

    # LOB 240 should have only ACA plans
    def is_aca_compliance_plan?
      true
    end

  end
end