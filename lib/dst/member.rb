require_relative 'member/check_point'
require_relative 'member/group'

module DST
  class Member < ::Sequel::Model(::SequelConnect::DB)
    include DST
    include MemberClass::CheckPoint
    include MemberClass::Group
    set_dataset :members_base_view
    set_primary_key :mem_no

    many_to_one :pcp, :class => :'DST::Physician', :key => [:physician, :mem_lob], :primary_key => [:provider_id, :lob]

    one_to_many :lob_240_benefit_plan_history, :key => :mem_id, :order => :eff_dt
    one_to_many :disenroll_records, :key => :mem_id

    def_column_alias :id, :mem_no

    ########## Typecasting ##########

    def beg_cov
      super.to_date
    end

    def birth
      super.to_date
    end

    def mem_reg_eff
      super.to_date
    end

    #################################

    def disenroll_records_on(date, include_cancel)
      ds = disenroll_records_dataset.on(date)
      ds = ds.exclude_cancel_records unless include_cancel
      ds.all
    end

    def benefit_plan(params={})
      date  = params.fetch(:on)
      group = group(params)
      if group.nil?
        NullRecord.new
      else
        if group.is_exchange?
          lob_240_benefit_plan_history_dataset.where('eff_dt <= ?', date).reverse(:eff_dt).first
        else
          group.benefit_plans_dataset.where('eff_dates <= ?', date).reverse(:eff_dates).first
        end
      end
    end

    def age(params={})
      now = params.fetch(:on, Time.now.utc.to_date)
      now.year - birth.year - ((now.month > birth.month || (now.month == birth.month && now.day >= birth.day)) ? 0 : 1)
    end

    dataset_module do
      subset :commercial, :mem_lob => COMMERCIAL_LOBS
      subset :exchange, :mem_lob => EXCHANGE_LOBS

      def active
        where(Sequel.&(Sequel.~(:disenr => 'D'), Sequel.~(:mem_lob => '')))
      end
    end
  end
end

