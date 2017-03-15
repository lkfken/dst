# coding: utf-8
module DST
  class ClaimBaseRecord < Sequel::Model(DST::DB)
    set_dataset :master_claim_base_view
    def_column_alias :member_id, :member

    many_to_one :_group, :key => :group_number, :primary_key => :group_id, :class => 'DST::Group'
    many_to_one :_physician, :key => :physician, :primary_key => :provider_id, :class => 'DST::Physician'
    many_to_one :_member, :key => :member, :primary_key => :mem_no, :class => 'DST::Member'
    one_to_many :claim_detail_base_records, :key => :document_no, :primary_key => :document_no
    def first_dos
      super.to_date
    end
  end
end