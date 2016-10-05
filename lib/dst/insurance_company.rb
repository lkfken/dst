module DST
  class InsuranceCompany < Sequel::Model(::DST::DB)
    set_primary_key :ins_comp_cd

    set_dataset :r_ins_company_base_view
    def_column_alias :name, :ins_desc
    def_column_alias :id, :ins_comp_cd
    one_to_many :other_insurances, :key => :ins_comp_cd, :primary_key => :ins_comp_cd
  end
end
