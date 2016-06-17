require 'date'
module DST
  class Lob240EdiBenefit < ::Sequel::Model(DST::DB)
    set_dataset :edi_benefits

    def benefitbegin
      Date.strptime(super, '%m/%d/%Y') unless super.nil?
    end

    def benefitend
      Date.strptime(super, '%m/%d/%Y') unless super.nil?
    end
  end
end