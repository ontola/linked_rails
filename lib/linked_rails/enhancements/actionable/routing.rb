# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Actionable
      module Routing; end

      class << self
        def route_concerns(mapper)
          mapper.concern :actionable do
            namespace :actions do
              mapper.resources :items, path: '', only: %i[show]
            end
          end
        end
      end
    end
  end
end
