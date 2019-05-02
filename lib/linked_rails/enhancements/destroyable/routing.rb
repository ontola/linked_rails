# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Destroyable
      module Routing; end

      class << self
        def route_concerns(mapper)
          mapper.concern :destroyable do
            mapper.member do
              mapper.get :delete, action: :delete, as: :delete
              mapper.delete '', action: :destroy, as: :destroy
            end
          end
        end
      end
    end
  end
end
