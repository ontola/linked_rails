# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Actionable
      module Serializer
        extend ActiveSupport::Concern

        included do
          triples :action_triples
        end
      end
    end
  end
end
