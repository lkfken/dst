module DST
  class Lob240EdiEnrollment < ::Sequel::Model(DST::DB)
    set_dataset :edi_enrollment
    def_column_alias :ssn, :memberid
    def_column_alias :cca_subscriber_id, :subscribernumber
    def_column_alias :cca_member_id, :memberid1
    def_column_alias :cchp_member_id, :memberid2
    def_column_alias :hios_id, :payerid
    def_column_alias :subscriber_indicator, :subscriberindicator
    def_column_alias :last_name, :memberlastname
    def_column_alias :first_name, :memberFirstName
    def_column_alias :middle_name, :memberMiddleName
    def_column_alias :ssn, :memberId
    def_column_alias :residential_zipcode, :memberzip

    def residential_address
      [memberaddress1, memberaddress2, membercity, memberstate, memberzip]
    end

    dataset_module do
      def cca_member_id(id)
        where(:memberid1 => id)
      end
    end
  end
end