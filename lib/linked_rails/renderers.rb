# frozen_string_literal: true

require 'rdf/serializers/renderers'
require 'rdf/nquads'
require 'rdf/ntriples'

module LinkedRails
  class Renderers
    class << self
      attr_accessor :rdf_content_types

      # Registers mime types and renderers for all available rdf formats.
      # Add additional formats by adding the gems to the Gemfile.
      # See https://github.com/ruby-rdf/rdf#rdf-serialization-formats for a list of available formats.
      def register!
        self.rdf_content_types = []
        RDF::Format.each do |format|
          register_renderer(format.file_extension, format.content_type, format.symbols.first)
        end

        register_renderer(%i[hndjson], ['application/hex+x-ndjson'], :hndjson)
        register_renderer(%i[empjson], ['application/empathy+json'], :empjson)
        rdf_content_types.freeze
      end

      private

      def prefixes
        @prefixes ||=
          RDF::Vocabulary.vocab_map.transform_values do |options|
            options[:class] || RDF::Vocabulary.from_sym(options[:class_name])
          end
      end

      def register_renderer(extensions, content_types, symbol)
        return if extensions.blank? || content_types.blank? || symbol.blank?

        rdf_content_types << symbol
        Mime::Type.register(content_types.first, symbol, content_types.drop(1), extensions - [symbol])

        extensions.each do |_extension|
          RDF::Serializers::Renderers.add_renderer(symbol, content_types.first, symbol, prefixes: prefixes)
        end
      end
    end
  end
end
