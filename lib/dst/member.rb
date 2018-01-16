require_relative 'member/boolean'
require_relative 'member/group'
require_relative 'member/lob'
require_relative 'member/medical_group'
require_relative 'member/rx_data'

# require_relative 'enrollment_record' unless defined?(DST::EnrollmentRecord)

module DST
  class Member < ::Sequel::Model(::DST::DB)
    class NoPreviousPCP < StandardError
    end
    include DST::MemberInstanceMethods::Boolean
    include DST::MemberInstanceMethods::Group
    include DST::MemberInstanceMethods::LOB
    include DST::MemberInstanceMethods::RxData
    include DST::MemberInstanceMethods::MedicalGroup

    set_dataset :members_base_view
    set_primary_key :mem_no

    def_column_alias :id, :mem_no
    def_column_alias :language, :primary_lang

    ########## associations ##########

    many_to_one :pcp, :class => :'DST::Physician', :key => [:physician, :mem_lob], :primary_key => [:provider_id, :lob]
    many_to_one :subscriber
    many_to_one :current_group, :class => :'DST::Group', :key => :group_num

    one_to_many :lob_240_benefit_plan_history, :key => :mem_id, :order => :eff_dt
    one_to_many :disenroll_records, :key => :mem_id #, :order => :begin_cov
    one_to_many :enrollment_records, :key => :mem_id
    one_to_many :medicare_events, :key => :memb_id, :order => :seq_num
    one_to_many :medical_group_events, :key => :mem_id
    one_to_many :other_insurances, :key => :mem_id

    one_to_one :last_disenroll_record, :clone => :disenroll_records do |ds|
      ds.last_disenroll_records
    end
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
      when group.is_exchange?
        plan = lob_240_benefit_plan_history_dataset.record!(on: date)
        plan.nil? ? DST::NullRecord.new : plan
      when group.nil?
        DST::NullRecord.new
      else
        group.benefit_plan(:on => date)
      end
    end

    def age(params={})
      now = params.fetch(:on, Time.now.utc.to_date)
      now.year - birth.year - ((now.month > birth.month || (now.month == birth.month && now.day >= birth.day)) ? 0 : 1)
    end

    def disenroll_date
      is_active? ? Date.civil(2999, 12, 31) : disenroll_records_dataset.last_disenroll_records.first.disenr_dt
    end

    def phones
      if other_phone.empty?
        a = []
        a << subscriber.home_phone.strip
        a << subscriber.work_phone.strip
        a.uniq.delete_if { |ph| ph.empty? }
      else
        other_phone
      end
    end

    def address
      { :line_1 => other_addr1.strip,
        :line_2 => other_addr2.strip,
        :line_3 => other_addr3.strip,
        :city   => other_city,
        :state  => other_state,
        :zip    => other_zip }
    end

    def residential_address
      member_address_exist? ? address : subscriber.address
    end

    def residential_zipcode
      residential_address.fetch(:zip)
    end

    def residential_city
      residential_address.fetch(:city)
    end

    def residential_state
      residential_address.fetch(:state)
    end

    def mailing_address
      subscriber.address
    end

    def mailing_address_block
      subscriber.address_block
    end

    def member_address_exist?
      !other_addr1.empty?
    end

    def last_name
      super.strip
    end

    def first_name
      super.strip
    end

    def full_name
      [first_name, last_name].delete_if { |n| n.empty? }.join(' ')
    end

    def no_pcp?
      %w[999999 999998].include?(physician)
    end

    def previous_pcp
      doctor = enrollment_records_dataset.exclude(:pcp_id => ['999998', '999999', ' '])
                   .reverse(:elig_eff_dt).select_group(:elig_eff_dt, :pcp_id).first
      raise NoPreviousPCP, "#{id} has no previous PCP." if doctor.nil?
      doctor.pcp_id
    end

    def family_dataset
      self.class.where(:subscriber_id => subscriber_id)
    end

    def family
      family_dataset.all
    end

    dataset_module do
      subset :commercial, :mem_lob => DST.commercial_lobs
      subset :exchange, :mem_lob => DST.exchange_lobs
      subset :hill_pcp, :mem_region => 'HPMG'
      subset :pcp_assigned, Sequel.~(:physician => ['999999', '999998', ''])
      subset :no_pcp_assigned, :physician => ['999999', '999998', '']

      eager :with_current_group, :current_group

      def in_groups(*group_ids)
        like_clauses = group_ids.map { |id| Sequel.like(:group_num, id.upcase + '%') }
        or_clause    = Sequel.|(*like_clauses)
        where(or_clause)
      end

      def append_disenroll_date
        disenroll_date = Sequel.function(:todatetimeoffset, '2999-12-31 00:00:00', '-08:00').cast(:datetime)
        select_append(disenroll_date.as(:disenroll_date))
      end

      def active
        where(Sequel.&(Sequel.~(:disenr => 'D'), Sequel.~(:mem_lob => '')))
      end

      def not_active
        where(:disenr => 'D').or(:mem_lob => '')
      end

      def subscriber_only
        where(:rel_code => 'P')
      end

      def eligible_on(date)
        date_ds             = Sequel.lit("begin_cov <= ? and disenr_dt >= ?", date, date)
        disenroll_record_ds = DST::DisenrollRecord.
            exclude_cancel_records.
            where(date_ds).select(:mem_id, :begin_cov)
        from_self(alias: :m).left_join(disenroll_record_ds, :mem_id => :mem_no)
            .where { ((beg_cov <= date) & (beg_cov > Date.civil(1900, 1, 1))) | (begin_cov <= date) }
            .select_all(:m).from_self
      end

      def medical_group_ds
        mod_region_to_mg = Sequel.case([[{ mem_region: 'SM' }, 'CCHCA'],
                                        [{ mem_region: 'SF' }, 'CCHCA']], :mem_region).as(:medical_group)
        select_all.select_more { mod_region_to_mg }.from_self
      end

      def lob_filter(params={})
        date = params.fetch(:on)
        lobs = params.fetch(:value)
        ds   = DST::EnrollmentRecord.eligible_on(:year => date.year, :month => date.month).where(:orig_lob_id => lobs).select_group(:mem_id)
        join(ds, :mem_id => :mem_no).select_all.from_self
      end

      def under_age(n, on_date: Date.today)
        cutoff_date = on_date.prev_year(n)
        where(Sequel.lit('birth > ?', cutoff_date))
      end

      def not_under_age(n, params={})
        on_date     = params.fetch(:on_date, Date.today)
        cutoff_date = on_date.prev_year(n)
        #warn "Age >= #{n} on #{on_date}.  DOB must be on or before #{cutoff_date}."
        where('birth <= ?', cutoff_date)
      end
    end
  end
end

require_relative 'member/ext/typecasting'
require_relative 'member/subset/commercial'
require_relative 'member/subset/LisSenior'