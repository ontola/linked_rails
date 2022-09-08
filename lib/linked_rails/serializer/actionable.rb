# frozen_string_literal: true

module LinkedRails
  module Serializer
    module Actionable
      extend ActiveSupport::Concern

      included do
        has_many :favorite_actions,
                 predicate: Vocab.ontola[:favoriteAction] do |object|
          object.try(:favorite_actions)
        end
        statements :action_triples
      end

      module ClassMethods
        def action_triples(object, _params)
          if named_object?(object) || object.try(:singular_resource?)
            object.try(:action_triples) || []
          else
            []
          end
        end
      end
    end
  end
end
