module DST
  class Member
    class Commercial < DST::Member
      set_dataset dataset.where(:mem_lob => DST.commercial_lobs).active
    end
  end
end