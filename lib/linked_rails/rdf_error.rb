# frozen_string_literal: true

module LinkedRails
  class RDFError
    include ActiveModel::Serialization
    include ActiveModel::Model

    attr_accessor :error, :iri, :status
    delegate :message, to: :error

    def initialize(status, requested_url, original_error)
      self.status = status
      self.error = original_error.is_a?(StandardError) ? original_error : original_error.new
      self.iri = ::RDF::URI(requested_url)
    end

    def graph
      g = ::RDF::Graph.new
      g << [iri, RDF::Vocab::SCHEMA.name, title] if title
      g << [iri, RDF::Vocab::SCHEMA.text, message]
      g << [iri, ::RDF[:type], type]
      g
    end

    def title
      @title ||= I18n.t('status')[status] || I18n.t('status')[500]
    end

    def type
      @type ||= Vocab::ONTOLA["errors/#{error.class.name.demodulize}Error"]
    end
  end
end
