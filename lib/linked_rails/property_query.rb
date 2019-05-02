# frozen_string_literal: true

module LinkedRails
  class PropertyQuery < SHACL::PropertyShape
    class << self
      def iri
        NS::ONTOLA[:PropertyQuery]
      end
    end
  end
end
