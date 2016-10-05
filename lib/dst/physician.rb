module DST
  class Physician < ::Sequel::Model(DST::DB)
    set_dataset :physician_base_view
    set_primary_key [:provider_id, :lob]

    def_column_alias :phone, :business_phone

    one_to_many :member, :key => [:provider_id, :lob], :primary_key => [:physician, :mem_lob]
    one_to_many :medical_groups, :class => :'DST::MedicalGroup', :key => [:provider, :lob]

    def full_name
      name = [first_name, last_name].delete_if(&:empty?).join(' ')
      name << ", #{title}" unless title.empty?
      name
    end

    def medical_groups(params={})
      start_date = params.fetch(:effective_start, Date.civil(1900, 1, 1))
      end_date   = params.fetch(:effective_end, Date.civil(2999, 12, 31))
      ds         = medical_groups_dataset.span(:start_date => start_date, :end_date => end_date)
      ds         = ds.active.pcp.current_records
      ds.select_group(:prov_capacity, :region).all.map(&:region_conv).uniq
    end

    def eligible_medical_groups(params={})
      date = params.fetch(:on)
      medical_groups_dataset.active.pcp.eligible(:on => date).all.map(&:region_conv).uniq
    end
  end
end