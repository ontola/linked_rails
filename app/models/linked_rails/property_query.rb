# frozen_string_literal: true

module LinkedRails
  class PropertyQuery < SHACL::PropertyShape
    attr_accessor :force_render

    class << self
      def iri
        Vocab.ontola[:PropertyQuery]
      end
    end
  end
end
