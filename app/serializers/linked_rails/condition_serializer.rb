# frozen_string_literal: true

module LinkedRails
  class ConditionSerializer < LinkedRails.serializer_parent_class
    has_one :fail, predicate: Vocab.ontola[:fail]
    has_one :pass, predicate: Vocab.ontola[:pass]
    has_one :shape, predicate: Vocab.sh.node
  end
end
