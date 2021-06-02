# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Updatable
      module Routing; end

      class << self
        def route_concerns(mapper)
          mapper.concern :updatable do
            mapper.member do
              mapper.patch :update
              mapper.put   :update
            end
          end
        end
      end
    end
  end
end
