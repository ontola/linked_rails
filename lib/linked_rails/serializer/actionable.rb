# frozen_string_literal: true

module LinkedRails
  module Serializer
    module Actionable
      extend ActiveSupport::Concern

      included do
        statements :action_triples
      end

      module ClassMethods
        def action_triples(object, _params)
          if object.iri.anonymous? && !object.try(:singular_resource?)
            []
          else
            object.try(:action_triples) || []
          end
        end
      end
    end
  end
end
