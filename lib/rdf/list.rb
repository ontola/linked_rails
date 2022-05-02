# frozen_string_literal: true

module RDF
  class List
    def serializer_class
      RDF::Serializers::ListSerializer
    end
  end
end
