# frozen_string_literal: true

module LinkedRails
  class CreativeWork
    include ActiveModel::Model
    include LinkedRails::Model

    attr_writer :iri
    attr_accessor :description, :name, :text, :url

    def iri(_opts = {})
      @iri ||= RDF::Node.new
    end

    class << self
      def iri
        RDF::Vocab::SCHEMA.CreativeWork
      end
    end
  end
end
