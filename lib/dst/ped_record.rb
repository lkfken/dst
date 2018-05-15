module DST
  class PedRecord < Sequel::Model(::DST::DB[:kt_ped_records])
    def group_renew_date
      super.to_date
    end

    def disenroll_date
      super.to_date
    end

    def effective_date
      super.to_date
    end

    def current_month
      super.to_date
    end

    dataset_module do
      def current
        date = max(:created_at).to_date
        created_on(date)
      end

      def created_on(date)
        where(Sequel.lit('created_at >= ? and created_at < ?', date, date.next_day))
      end
    end
  end
end
