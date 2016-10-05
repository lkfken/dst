module DST
  class DisenrollReason < ::Sequel::Model(DST::DB)
    set_dataset :r_disenrl_reason_base_view
    set_primary_key :disenrl_rsn_cd

    def_column_alias :id, :disenrl_rsn_cd
    def_column_alias :description, :disenrl_rsn_desc

    ########## associations ##########

    one_to_many :disenroll_records, :key => :dis_reas

    ##################################

  end
end

