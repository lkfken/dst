module DST
  class DisenrollRecord < ::Sequel::Model(::SequelConnect::DB)
    set_dataset :disenroll_base_view
    many_to_one :member

  end
end