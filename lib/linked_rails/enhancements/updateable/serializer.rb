# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Updateable
      module Serializer
        extend ActiveSupport::Concern

        included do
          attribute :updated_at,
                    predicate: NS::SCHEMA[:dateModified]
        end

        def updated_at
          object.try(:updated_at)
        end
      end
    end
  end
end
