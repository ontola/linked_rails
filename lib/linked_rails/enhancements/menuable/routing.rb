# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Menuable
      module Routing; end

      class << self
        def route_concerns(mapper)
          mapper.concern :menuable do
            scope module: :menus do
              mapper.resources :lists, only: %i[index show], path: 'menus' do
                mapper.resources :items, only: %i[index], path: 'menus'
              end
            end
          end
        end
      end
    end
  end
end
