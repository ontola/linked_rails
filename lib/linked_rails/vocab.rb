# frozen_string_literal: true

require 'rdf'

module LinkedRails
  class Vocab
    class CustomVocabulary < RDF::Vocabulary
      def key=(value)
        @__key__ = value
      end

      def __name__
        @__key__
      end

      def __prefix__
        __name__.split('::').last.downcase.to_sym
      end
    end
    def self.define_shortcut(key)
      define_singleton_method(key) do
        options = RDF::Vocabulary.vocab_map.fetch(key)
        options[:class] || RDF::Vocabulary.from_sym(options[:class_name])
      end
    end

    def self.register(key, uri)
      klass = CustomVocabulary.new(uri)
      klass.key = key.to_s.classify.upcase
      RDF::Vocabulary.register(key, uri, class: klass)
      define_shortcut(key)
    end

    RDF::Vocabulary.vocab_map.each_key do |key|
      define_shortcut(key)
    end

    register(:fhir, 'http://hl7.org/fhir/')
    register(:form, 'https://ns.ontola.io/form#')
    register(:libro, 'https://ns.ontola.io/libro/')
    register(:ll, 'http://purl.org/link-lib/')
    register(:ontola, 'https://ns.ontola.io/core#')
    register(:sp, 'http://spinrdf.org/sp#')
  end
end
