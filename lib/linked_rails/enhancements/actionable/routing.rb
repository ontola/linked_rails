# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Actionable
      module Routing; end

      class << self
        def route_concerns(mapper)
          mapper.concern :actionable do
            mapper.resources :action_items, path: 'actions', only: %i[index show]
          end
        end
      end
    end
  end
end
