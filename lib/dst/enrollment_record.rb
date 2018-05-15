module DST
  class EnrollmentRecord < ::Sequel::Model(DST::DB)
    set_dataset :wd_enrollment_base_view

    def_column_alias :member_id, :mem_id
    def_column_alias :id, :mem_id
    def_column_alias :group_id, :grp_id
    def_column_alias :lob, :orig_lob_id
    def_column_alias :effective_date, :elig_eff_dt
    def_column_alias :disenroll_date, :elig_exp_dt

    ########## associations ##########
    many_to_one :member
    many_to_one :group
    ##################################

    dataset_module do
      def member_count
        select_group(:mem_id).count
      end

      def exclude_cancel_records
        exclude(:elig_eff_dt => :elig_exp_dt)
      end

      def append_min_eff_dt
        min_table = select_group(:mem_id).exclude_cancel_records.select_append { min(:elig_eff_dt).as(:min_eff_dt) }
        from_self(:alias => :omin).join(min_table, { :min__mem_id => :omin__mem_id }, :table_alias => :min)
      end

      def append_max_exp_dt
        max_table = select_group(:mem_id).exclude_cancel_records.select_append { max(:elig_exp_dt).as(:max_exp_dt) }
                        .from_self(:alias => :maxt)
        from_self(:alias => :omax).join(max_table, { :max__mem_id => :omax__mem_id }, :table_alias => :max)
      end

      def eligible_within(span:)
        raise "#{span} is not a range" if !span.respond_to?(:end) && !span.respond_to?(:begin)
        exclude_cancel_records.where(Sequel.lit('ELIG_EFF_DT < ? AND ELIG_EXP_DT >= ?', span.end, span.begin))
      end

      def eligible_on(params={})
        year        = params.fetch(:year)
        month       = params.fetch(:month)
        day         = params.fetch(:day, 1)
        date        = Date.civil(year, month, day)
        cutoff_date = Date.parse(Date.today.next_month.strftime("%Y%m01"))
        raise [".#{caller_locations(0).first.label}", DST::EnrollmentRecord.table_name, "is not ready until #{cutoff_date.strftime('%m/%d/%Y')}!!"].join(' ') if date >= cutoff_date
        lit = Sequel.lit('ELIG_EFF_DT <= ? and ELIG_EXP_DT >= ?', date, date)
        exclude_cancel_records.where(lit)
      end

      def islands(partition)
        gaps = gaps(partition)
        case
        when gaps.empty?
          min_elig_eff_dt = DST::EnrollmentRecord.where(partition).min(:elig_eff_dt)
          max_elig_exp_dt = DST::EnrollmentRecord.where(partition).max(:elig_exp_dt)
          [{ :elig_eff_dt => min_elig_eff_dt, :elig_exp_dt => max_elig_exp_dt }]
        else
          gaps.flat_map do |gap|
            ds              = DST::EnrollmentRecord.where(partition).where('elig_exp_dt < ?', gap[:gap_begin])
            min_elig_eff_dt = ds.min(:elig_eff_dt)
            max_elig_exp_dt = ds.max(:elig_exp_dt)
            i               = [{:elig_eff_dt => min_elig_eff_dt, :elig_exp_dt => max_elig_exp_dt }]
            ds              = DST::EnrollmentRecord.where(partition).where('elig_eff_dt > ?', gap[:gap_end])
            if !ds.empty?
              min_elig_eff_dt = ds.min(:elig_eff_dt)
              max_elig_exp_dt = ds.max(:elig_exp_dt)
              i << { :elig_eff_dt => min_elig_eff_dt, :elig_exp_dt => max_elig_exp_dt }
            end
          end
        end
      end

      def gaps(partition)
        columns       = partition.keys.join(',').upcase
        filter_clause = partition.map { |a| "[#{a[0].upcase}] = N'#{a[1]}'" }.join(' AND ')
        statement     = <<-SQL
          WITH C1 AS (
            SELECT
            #{columns},
            ts,
            Type,
            e = CASE Type
                WHEN 1
                  THEN NULL
                ELSE ROW_NUMBER()
                OVER (PARTITION BY #{columns}, Type
                  ORDER BY elig_exp_dt) END,
            s = CASE Type
                WHEN -1
                  THEN NULL
                ELSE ROW_NUMBER()
                OVER (PARTITION BY #{columns}, Type
                  ORDER BY elig_eff_dt) END
            FROM wd_enrollment_base_view
            CROSS APPLY (VALUES (1, elig_eff_dt), (-1, elig_exp_dt)) a(Type, ts)),
          C2 AS (
            SELECT
              C1.*,
                se = ROW_NUMBER()
              OVER (PARTITION BY #{columns}
                ORDER BY ts, Type DESC)
            FROM C1),
          C3 AS (
            SELECT
              #{columns},
              ts,
                grpnm = FLOOR((ROW_NUMBER()
                               OVER (PARTITION BY #{columns}
                                 ORDER BY ts) - 1) / 2 + 1)
            FROM C2
            WHERE COALESCE(s - (se - s) - 1, (se - e) - e) = 0),
          -- C1, C2, C3, C4 combined remove the overlapping date periods
          C4 AS (
            SELECT
              #{columns},
                elig_eff_dt = MIN(ts),
                elig_exp_dt = MAX(ts)
            FROM C3
            GROUP BY #{columns}, grpnm)
          SELECT
            #{columns},
              gap_begin = MIN(newdate),
              gap_end = MAX(newdate)
          FROM (
                 SELECT
                   #{columns},
                   newdate,
                     rn = ROW_NUMBER()
                          OVER (PARTITION BY #{columns}
                            ORDER BY newdate) / 2
                 FROM C4 a
                   CROSS APPLY (
                                 VALUES (elig_eff_dt - 1), (elig_exp_dt + 1)) b(newdate)
          ) a
          WHERE #{filter_clause}
          GROUP BY #{columns}, rn
          HAVING COUNT(*) = 2
          ORDER BY #{columns}, gap_begin;
        SQL

        rs = DST::DB.fetch(statement).all
        rs.select { |r| r[:gap_begin].to_date.next_day != r[:gap_end].to_date }
      end
    end

  end
end
