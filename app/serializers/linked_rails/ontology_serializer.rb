# frozen_string_literal: true

module LinkedRails
  class OntologySerializer < LinkedRails.serializer_parent_class
    has_many :classes
    has_many :properties
  end
end
