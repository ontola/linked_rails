# frozen_string_literal: true

module LinkedRails
  class SequenceSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer

    has_many :members, predicate: ->(relationship, index) do
      RDF["_#{index}"]
    end
  end
end
