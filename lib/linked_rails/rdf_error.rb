# frozen_string_literal: true

module LinkedRails
  class RDFError
    include ActiveModel::Model

    attr_accessor :error, :iri, :message, :status

    def initialize(status, requested_url, original_error)
      self.status = status
      self.error = original_error.is_a?(StandardError) ? original_error : original_error.new
      self.message = error.message unless Rails.env.production?
      self.iri = ::RDF::URI(requested_url)
    end

    def graph # rubocop:disable Metrics/AbcSize
      g = ::RDF::Graph.new
      g << [iri, Vocab.schema.name, title] if title
      g << [iri, Vocab.schema.text, message]
      g << [iri, Vocab.rdfv.type, rdf_type]
      g
    end

    def title
      @title ||= I18n.t('linked_rails.status')[status] || I18n.t('linked_rails.status')[500]
    end

    def rdf_type
      @rdf_type ||= Vocab.ontola["errors/#{error.class.name.demodulize}Error"]
    end

    def self.serializer_class
      RDFErrorSerializer
    end
  end
end
