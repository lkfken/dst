module DST
  module MemberInstanceMethods
    module RxData
      def rx_id(params={})
        lob = params.fetch(:lob)
        if DST::medicare_lobs.include?(lob)
          subscriber_id
        else
          mem_no
        end
      end

      def rx_group(params={})
        lob            = params.fetch(:lob)
        effective_date = params.fetch(:effective_date, Date.today)
        case lob
        when '253'
          effective_date.year <= 2014 ? 'CPM' : 'CPMSP2530'
        when '250', '256'
          effective_date.year <= 2014 ? 'CPM' : 'CPMSP2500'
        when '100', '110'
          'CPC'
        when '140', '240'
          'CCX'
        else
          raise "Unknown RX Group for LOB #{lob}"
        end
      end

      def rx_bin(params={})
        lob = params.fetch(:lob)
        case lob
        when /^[12]\d\d$/
          '610602'
        else
          raise "Unknown RX Group for LOB #{lob}"
        end
      end

      def rx_pcn(params={})
        lob = params.fetch(:lob)
        case lob
        when /^25/
          'NVTD'
        when /^(1\d|2[^5])\d{1}$/
          'NVT'
        else
          raise "Unknown RX Group for LOB #{lob}"
        end
      end

      def issuer_id
        '(80840)1184901746'
      end
    end
  end
end