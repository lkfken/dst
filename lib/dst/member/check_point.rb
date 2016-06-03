module DST
  module MemberClass
    module CheckPoint
      def is_active?
        !is_disenrolled?
      end

      def is_disenrolled?
        disenr == 'D' || group_num == ''
      end

      def is_eligible_on?(date)
        return true if is_active? && beg_cov <= date
        records = disenroll_records_dataset.exclude_cancel_records.on(date)
        !records.count.zero?
      end
    end
  end
end