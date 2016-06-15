require 'date'
module DST
  class Lob240EdiBenefit < ::Sequel::Model(DST::DB)
    set_dataset :edi_benefits

    def benefitbegin
      Date.parse(super) unless super.nil?
    end

    def benefitend
      Date.parse(super) unless super.nil?
    end
  end
end