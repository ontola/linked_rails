# frozen_string_literal: true

module LinkedRails
  module Actions
    class ObjectSerializer < LinkedRails.serializer_parent_class
      has_one :object, predicate: Vocab.owl.sameAs
    end
  end
end
