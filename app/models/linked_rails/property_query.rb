# frozen_string_literal: true

module LinkedRails
  class PropertyQuery < SHACL::PropertyShape
    class << self
      def iri
        Vocab::ONTOLA[:PropertyQuery]
      end
    end
  end
end
