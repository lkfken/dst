module DST
  class OtherInsurance < Sequel::Model(::DST::DB)

    set_dataset :r_mem_ins_base_view
    def_column_alias :member_id, :mem_id
    def_column_alias :cob_id, :ins_comp_cd

    many_to_one :member
    many_to_one :insurance_company, :key => :ins_comp_cd, :primary_key => :ins_comp_cd

    def effective_date
      mem_other_ins_elig_dt
    end

    def term_date
      mem_other_ins_exp_dt
    end

    def is_vsp?
      insurance_company.id == 'C041'
    end

    def is_ash?
      insurance_company.id == 'C042'
    end

    def is_delta?
      insurance_company.id == 'C161'
    end

    def mem_other_ins_elig_dt
      super.to_date
    end

    def mem_other_ins_exp_dt
      super.to_date
    end

    def name
      self.insurance_company.name
    end

    dataset_module do
      def vsp
        filter(:ins_comp_cd => 'C041')
      end

      def ash
        filter(:ins_comp_cd => 'C042')
      end

      def delta_dental
        filter(:ins_comp_cd => 'C161')
      end

      def active
        where(:mem_other_ins_exp_dt => Date.civil(2999, 12, 31))
      end

      def eligible_on(date: Date.today)
        where(Sequel.lit('mem_other_ins_elig_dt <= ? and mem_other_ins_exp_dt > ?', date, date))
      end
    end

  end
end
