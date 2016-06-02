module DST
  class Group < ::Sequel::Model(::SequelConnect::DB)
    set_dataset :cchp_groups_base
    set_primary_key :group_id

    one_to_many :benefit_plans, :key => :group_id, :primary_key => :group_id
    one_to_many :disenroll_records, :key => :c_grp
    one_to_many :members, :key => :group_num

    def_column_alias :id, :group_id

    def is_exchange?
      DST.exchange_lobs.include?(lob)
    end

    def benefit_plan(params={})
      benefit_plans_dataset.record!(params)
    end
  end
end