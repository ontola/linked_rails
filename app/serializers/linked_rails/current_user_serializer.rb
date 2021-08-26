# frozen_string_literal: true

module LinkedRails
  class CurrentUserSerializer < LinkedRails.serializer_parent_class
    attribute :actor_type, predicate: Vocab.ontola[:actorType]
  end
end
