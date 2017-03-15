class Array
  def rows
    map { |record| record.data_only }
  end

  def headings
    first.headings
  end
end