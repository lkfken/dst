module MemberClass
  module Group
    def group_ids(params={})
      date           = params.fetch(:on)
      include_cancel = params.fetch(:include_cancel, true)
      ids            = disenroll_records_on(date, include_cancel).map(&:group_id)
      ids << group_num if is_active? && date >= beg_cov
      ids.sort
    end

    def group_id(params={})
      date = params.fetch(:on)
      group_ids(:on => date, :include_cancel => false).first
    end

    def group(params={})
      date = params.fetch(:on) { raise KeyError, 'Missing :on => [date]' }
      return DST::NullRecord.new unless is_eligible_on?(date)
      DST::Group.where(:group_id => group_id(on: date)).first
    end
  end
end