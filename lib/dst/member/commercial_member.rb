module DST
  class CommercialMember < DST::Member
    set_dataset dataset.where(:mem_lob => DST.commercial_lobs).active
  end
end