# frozen_string_literal: true

module LinkedRails
  class ConditionSerializer < LinkedRails.serializer_parent_class
    has_one :fail, predicate: Vocab.ontola[:fail], polymorphic: true
    has_one :pass, predicate: Vocab.ontola[:pass], polymorphic: true
    has_one :shape, predicate: Vocab.sh.node, polymorphic: true
  end
end
