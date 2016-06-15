module DST
  class MedicareEvent < ::Sequel::Model(DST::DB)
    set_dataset :mr_members_base_view

    def_column_alias :member_id, :memb_id

    ########## associations ##########

    many_to_one :member

    ##################################

  end
end