# frozen_string_literal: true

module LinkedRails
  class SequenceSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer

    statements :sequence
    has_many :members, polymorphic: true

    def self.sequence(object, _params)
      object.sequence
    end
  end
end
