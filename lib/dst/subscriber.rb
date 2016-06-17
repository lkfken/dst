module DST
  class Subscriber < ::Sequel::Model(DST::DB)
    set_dataset :subscribers_base_view
    set_primary_key :subscriber_id

    def_column_alias :id, :subscriber_id

    ########## associations ##########

    one_to_many :members

    ##################################

    def member_record
      members_dataset.subscriber_only.first
    end

  end
end