require_relative '../../../../lib/dst/medicare_event'
module DST
  class Member
    class LisSenior < ::DST::Member
      set_dataset dataset
                      .eligible_on(Date.today)
                      .lob_filter(:on => Date.today, :value => DST::medicare_lobs)
                      .where(:mem_lob => DST.medicare_lobs)
                      .join(DST::MedicareEvent.current_lis_event, :memb_id => :mem_no)
                      .from_self
      dataset_module do
        def ds(date: Date.today)
          DST::Member.dataset
              .eligible_on(date)
              .lob_filter(:on => Date.today, :value => DST::medicare_lobs)
              .where(:mem_lob => DST.medicare_lobs)
              .join(DST::MedicareEvent.current_lis_event(date: date)
                        .select(:memb_id, :li_cpy_dt, :li_cpy_ind, :li_sub_dt, :li_sub_ind), :memb_id => :mem_no)
              .from_self
        end
        def null_lis
          where('li_cpy_dt <= ? or li_sub_dt <= ?', Date.civil(1970, 1, 1), Date.civil(1970, 1, 1))
        end

        def no_lis
          where('li_cpy_ind = 0 or li_sub_ind = 0')
        end
      end
    end
  end
end