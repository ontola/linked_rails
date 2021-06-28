# frozen_string_literal: true

module LinkedRails
  class Form
    class Field
      class ResourceFieldSerializer < FieldSerializer
        attribute :url, predicate: Vocab.schema.url
      end
    end
  end
end
