require_relative 'member/boolean'
require_relative 'member/group'
require_relative 'member/lob'

module DST
  class Member < ::Sequel::Model(::DST::DB)
    include DST::MemberInstanceMethods::Boolean
    include DST::MemberInstanceMethods::Group
    include DST::MemberInstanceMethods::LOB

    set_dataset :members_base_view
    set_primary_key :mem_no

    def_column_alias :id, :mem_no

    ########## associations ##########

    many_to_one :pcp, :class => :'DST::Physician', :key => [:physician, :mem_lob], :primary_key => [:provider_id, :lob]
    one_to_many :lob_240_benefit_plan_history, :key => :mem_id, :order => :eff_dt
    one_to_many :disenroll_records, :key => :mem_id
    one_to_many :medicare_events, :key => :memb_id
    many_to_one :subscriber
    ##################################

    def disenroll_records_on(date, include_cancel)
      ds = disenroll_records_dataset.on(date)
      ds = ds.exclude_cancel_records unless include_cancel
      ds.all
    end

    def benefit_plan(params={})
      date  = params.fetch(:on) { raise KeyError, 'Missing :on => [date]' }
      group = group(on: date)
      case
      when group.nil?
        DST::NullRecord.new
      when group.is_exchange?
        lob_240_benefit_plan_history_dataset.record!(on: date)
      else
        group.benefit_plan(:on => date)
      end
    end

    def age(params={})
      now = params.fetch(:on, Time.now.utc.to_date)
      now.year - birth.year - ((now.month > birth.month || (now.month == birth.month && now.day >= birth.day)) ? 0 : 1)
    end

    dataset_module do
      subset :commercial, :mem_lob => DST.commercial_lobs
      subset :exchange, :mem_lob => DST.exchange_lobs
      subset :hill_pcp, :mem_region => 'HPMG'

      def active
        where(Sequel.&(Sequel.~(:disenr => 'D'), Sequel.~(:mem_lob => '')))
      end

      def subscriber_only
        where(:rel_code => 'P')
      end

      def eligible_on(date)
        left_join(DST::DisenrollRecord.exclude_cancel_records.where('begin_cov <= ? and disenr_dt >= ?', date, date).select(:mem_id, :begin_cov), :mem_id => :mem_no)
            .where { ((beg_cov <= date) & (beg_cov > Date.civil(1900, 1, 1))) | (begin_cov <= date) }
      end

    end
  end
end

require_relative 'member/ext/typecasting'
require_relative 'member/subset/commercial'