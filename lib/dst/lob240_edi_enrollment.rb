module DST
  class Lob240EdiEnrollment < ::Sequel::Model(DST::DB)
    set_dataset :edi_enrollment
    def_column_alias :ssn, :memberid
    def_column_alias :cca_subscriber_id, :subscribernumber
    def_column_alias :cca_member_id, :memberid1
    def_column_alias :cchp_member_id, :memberid2

    def_column_alias :subscriber_indicator, :subscriberindicator
    def_column_alias :last_name, :memberlastname
    def_column_alias :first_name, :memberFirstName
    def_column_alias :middle_name, :memberMiddleName
    def_column_alias :ssn, :memberId
    def_column_alias :residential_zipcode, :memberzip

    def hios_id
      payerid[0..13]
    end

=begin
HIOS Standard Component ID with CSR variant
e.g. 12345UT0010001-00 where
12345 is the unique Issuer HIOS ID
UT is the state code for Utah
0010001 is Issuer defined and indicates a specific plan
-00 is the cost sharing variant such that
-00 off exchange
-01 on exchange
-02 zero cost sharing
-03 limited cost sharing
-04 73% AV Silver
-05 87% AV Silver
-06 94% AV Silver
=end

    def payerid
      raise "Plan ID should have 16 characters, but #{super} has only #{super.length}" if super.length != 16
      super
    end

    alias_method :plan_id, :payerid

    def cost_sharing_reduction_factor
      payerid[14..15]
    end

    alias_method :csr_variant, :cost_sharing_reduction_factor

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