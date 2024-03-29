# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Updatable
      module Serializer
        extend ActiveSupport::Concern

        included do
          attribute :updated_at, predicate: Vocab.schema.dateModified do |object|
            object.try(:updated_at)
          end
        end
      end
    end
  end
end
