# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Destroyable
      module Routing; end

      class << self
        def route_concerns(mapper)
          mapper.concern :destroyable do
            mapper.member do
              mapper.delete '', action: :destroy
            end
          end
        end
      end
    end
  end
end
