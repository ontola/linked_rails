# frozen_string_literal: true

module LinkedRails
  class PropertyQuerySerializer < SHACL::PropertyShapeSerializer
    attribute :force_render, predicate: Vocab.ll[:forceRender]
  end
end
