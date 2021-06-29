# frozen_string_literal: true

require_relative './base'

module LinkedRails
  class Ontology
    class Property < Base
      class << self
        def translation_key
          :property
        end

        def iri
          RDF[:Property]
        end
      end
    end
  end
end
