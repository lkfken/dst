module DST
  module MemberInstanceMethods
    module Boolean
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

      def is_subscriber?
        rel_code == 'P'
      end
    end
  end
end