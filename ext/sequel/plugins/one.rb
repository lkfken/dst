module Sequel
  class NotOneRow < Error
    def initialize(msg='Expected query to produce exactly 1 row!')
      super
    end
  end
  module Plugins
    module One
      module DatasetMethods
        def one
          rows = fetch_two
          rows.one? ? rows.first : fail(NotOneRow)
        end

        private

        def fetch_two
          limit(2).all
        end
      end
    end
  end
end