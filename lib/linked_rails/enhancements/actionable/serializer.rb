# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Actionable
      module Serializer
        extend ActiveSupport::Concern

        included do
          statements :action_triples
        end

        class_methods do
          def action_triples(object, params)
            object.action_triples(params[:scope])
          end
        end
      end
    end
  end
end
