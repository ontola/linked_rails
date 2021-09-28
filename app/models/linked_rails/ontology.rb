# frozen_string_literal: true

module LinkedRails
  class Ontology
    include ActiveModel::Model
    include LinkedRails::Model

    def classes
      @classes ||= ApplicationRecord.descendants.map do |klass|
        iri = klass.iri.is_a?(Array) ? klass.iri.first : klass.iri

        LinkedRails.ontology_class_class.new(klass: klass, iri: iri)
      end
    end

    def properties
      classes.flat_map(&:properties)
    end

    def root_relative_iri
      RDF::URI('/ns/core')
    end

    class << self
      def preview_includes
        %i[classes properties]
      end

      def requested_resource(opts, _user_context)
        LinkedRails.ontology_class.new if opts[:iri].ends_with?(new.root_relative_iri)
      end
    end
  end
end
