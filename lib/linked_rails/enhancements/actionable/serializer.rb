# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Actionable
      module Serializer
        extend ActiveSupport::Concern

        included do
          triples :action_triples
        end

        def action_triples
          object.action_triples(scope)
        end
      end
    end
  end
end
