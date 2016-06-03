require_relative 'physician/medical_group'
module DST
  class Physician < ::Sequel::Model(::SequelConnect::DB)

    set_dataset :physician_base_view
    set_primary_key [:provider_id, :lob]

    one_to_many :member, :key => [:provider_id, :lob], :primary_key => [:physician, :mem_lob]
    one_to_many :medical_groups, :class => :'DST::MedicalGroup', :key => [:provider, :lob]
  end
end