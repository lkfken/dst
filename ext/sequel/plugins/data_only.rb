module Sequel
  module Plugins
    module DataOnly
      module InstanceMethods
        def data_only
          values.map { |_, v| v }
        end

        def headings
          keys
        end
      end
    end
  end
end