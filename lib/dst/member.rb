module DST
  class Member < ::Sequel::Model(::SequelConnect::DB)
    set_dataset :members_base_view
    set_primary_key [:mem_no]

    many_to_one :group
    many_to_one :pcp, :class => :'DST::Physician', :key => [:physician, :mem_lob], :primary_key => [:provider_id, :lob]

    one_to_many :lob_240_benefit_plan_history, :key => :mem_id, :order => :eff_dt
    one_to_many :disenroll_records, :key => :mem_id

    def is_active?
      !is_disenrolled?
    end

    def is_disenrolled?
      disenr == 'D' || group_num == ''
    end

    def group_id(params={})
      date     = params.fetch(:on, beg_cov)
      return group_num if is_active? && date >= beg_cov
      disenrolled_group_id_on(date)
    end

    def disenrolled_group_id_on(date)
      return disenroll_records.first.group_id if date.year == 1899
      record = disenroll_records_dataset.exclude_cancel_records.filter_by_date(date).first
      record.nil? ? nil : record.group_id
    end

    def benefit_plan(params={})
      date     = params.fetch(:on, beg_cov)
      group_id = group_id(on: date)
      if group_id.nil?
        nil
      else
        group = DST::Group.where(:group_id => group_id).first
        if group.is_exchange?
          lob_240_benefit_plan_history_dataset.where('eff_dt <= ?', date).reverse(:eff_dt).first
        else
          group.benefit_plans_dataset.where('eff_dates <= ?', date).reverse(:eff_dates).first
        end
      end
    end

    dataset_module do
      def active
        where(Sequel.&(Sequel.~(:disenr => 'D'), Sequel.~(:mem_lob => '')))
      end
    end
  end
end