# frozen_string_literal: true

module LinkedRails
  class CreativeWork
    include ActiveModel::Model
    include ActiveModel::Serialization
    include LinkedRails::Model

    attr_writer :iri
    attr_accessor :description, :name, :text, :url

    def iri
      @iri ||= RDF::Node.new
    end

    class << self
      def iri
        NS::SCHEMA[:CreativeWork]
      end
    end
  end
end
