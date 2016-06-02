module DST
  class Group < ::Sequel::Model(::SequelConnect::DB)
    set_dataset :cchp_groups_base
    set_primary_key :group_id

    one_to_many :members, :key => :group_num
    one_to_many :disenroll_records, :key => :c_grp

    def_column_alias :id, :group_id

    def is_exchange?
      DST.exchange_lobs.include?(lob)
    end
  end
end