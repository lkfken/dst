module DST
  class Physician < ::Sequel::Model(::SequelConnect::DB)
    set_dataset :physician_base_view
    one_to_many :member, :key => [:provider_id, :lob], :primary_key => [:physician, :mem_lob]

  end
end