module DST
  class Member
    class Commercial < DST::Member
      set_dataset dataset.where(:mem_lob => DST.off_exchange_commercial_lobs).active
    end
  end
end