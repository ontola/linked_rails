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
          def action_triples(object, _params)
            if object.iri.anonymous? && !object.singular_resource?
              []
            else
              object.action_triples
            end
          end
        end
      end
    end
  end
end
