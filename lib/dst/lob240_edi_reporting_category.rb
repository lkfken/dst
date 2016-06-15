module DST
  class Lob240EdiReportingCategory < ::Sequel::Model(DST::DB)
    set_dataset :edi_reportingcategories

    def effectivedatestart
      super.to_date
    end

  end
end