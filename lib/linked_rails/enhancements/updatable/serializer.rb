# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Updatable
      module Serializer
        extend ActiveSupport::Concern

        included do
          attribute :updated_at,
                    predicate: RDF::Vocab::SCHEMA.dateModified
        end

        def updated_at
          object.try(:updated_at)
        end
      end
    end
  end
end
