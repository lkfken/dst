module DST
  class Member < ::Sequel::Model(::SequelConnect::DB)
    set_dataset :members_base_view
    set_primary_key [:mem_no]
    many_to_one :pcp, :class => :'DST::Physician', :key => [:physician, :mem_lob], :primary_key => [:provider_id, :lob]

    dataset_module do
      def active
        where(Sequel.&(Sequel.~(:disenr => 'D'), Sequel.~(:mem_lob => '')))
      end
    end
  end
end