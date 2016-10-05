module DST
  class Subscriber < ::Sequel::Model(DST::DB)
    set_dataset :subscribers_base_view
    set_primary_key :subscriber_id

    def_column_alias :id, :subscriber_id

    ########## associations ##########

    one_to_many :members
    one_to_many :lob240_grace_period_letters
    ##################################

    def is_active?
      member_record.is_active?
    end

    def member_record
      members_dataset.subscriber_only.first
    end

    def address
      { :line_1 => addr1.strip,
        :line_2 => addr2.strip,
        :line_3 => addr3.strip,
        :city   => city,
        :state  => state,
        :zip    => zip }
    end

    def address_block
      line1   = address[:line_1]
      line2   = [address[:line_2], address[:line_3]].delete_if { |s| s.empty? }.compact.join(', ')
      line3   = "#{address[:city]}, #{address[:state]} #{address[:zip]}"
      [line1, line2, line3].delete_if { |s| s.empty? }.compact.join("\n")
    end
  end
end