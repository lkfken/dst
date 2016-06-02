class NullRecord

  def nil?
    true
  end

  def method_missing(*args, &block)
    self
  end

end