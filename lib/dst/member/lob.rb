module DST
  module MemberInstanceMethods
    module LOB
      def lobs(params={})
        group_ids            = self.group_ids(params)
        DST::Group.where(:group_id => group_ids).all.map(&:lob)
      end

      def lob(params={})
        date = params.fetch(:on)
        lobs(:on => date, :include_cancel => false).first
      end
    end
  end
end