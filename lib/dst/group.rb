module DST
  class Group < ::Sequel::Model(::SequelConnect::DB)
    set_dataset :cchp_groups_base
    one_to_many :members, :key => :group_num, :primary_key => :group_id

    def is_exchange?
      %w[140 240].include?(lob)
    end
  end
end