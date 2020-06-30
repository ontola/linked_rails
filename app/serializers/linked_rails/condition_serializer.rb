# frozen_string_literal: true

module LinkedRails
  class ConditionSerializer < LinkedRails.serializer_parent_class
    has_one :fail, predicate: Vocab::ONTOLA[:fail]
    has_one :pass, predicate: Vocab::ONTOLA[:pass]
    has_one :shape, predicate: RDF::Vocab::SH.node
  end
end
