module DST
  class MedicareEvent < ::Sequel::Model(::SequelConnect::DB)
    set_dataset :mr_members_base_view

    def_column_alias :member_id, :memb_id

  end
end