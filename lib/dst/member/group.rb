module DST
  module MemberInstanceMethods
    module Group
      class MultipleGroupIdOnDateError < StandardError
        def initialize(params={})
          date      = params.fetch(:date)
          member_id = params.fetch(:member_id)
          group_ids = params.fetch(:group_ids)
          msg       = "On #{date}, multiple group ID #{group_ids} found for member #{member_id}"
          super(msg)
        end
      end
      class NoGroupIdOnDateError < StandardError
        def initialize(params={})
          date      = params.fetch(:date)
          member_id = params.fetch(:member_id)
          msg       = "On #{date}, no group ID found for member #{member_id}"
          super(msg)
        end
      end

      def group_ids(params={})
        date           = params.fetch(:on)
        include_cancel = params.fetch(:include_cancel, true)

        ids = disenroll_records_on(date, include_cancel).map(&:group_id)
        ids << group_num if is_active? && date >= beg_cov
        ids
      end

      def group_id(params={})
        date = params.fetch(:on)
        return nil unless is_eligible_on?(date)
        ids  = group_ids(:on => date, :include_cancel => false)
        raise(MultipleGroupIdOnDateError, :date => date, :member_id => id, :group_ids => ids) if ids.size > 1
        ids.first
      end

      def group(params={})
        date = params.fetch(:on) { raise KeyError, 'Missing :on => [date]' }
        return DST::NullRecord.new unless is_eligible_on?(date)
        DST::Group.where(:group_id => group_id(on: date)).first
      end
    end
  end
end