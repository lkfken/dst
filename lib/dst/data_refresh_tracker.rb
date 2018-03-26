module DST
  class DataRefreshTracker < Sequel::Model(::DST::DB)
    set_dataset :datarefreshtracker
    set_primary_key :refreshdate
    def_column_alias :date, :refreshdate

    dataset_module do
      def pass?(date: Date.today)
        status(date: date) == 'successed'
      end

      def status(date: Date.today)
        record = where(refreshdate: date).first
        record.statuscheck if record
      end
    end
  end
end
