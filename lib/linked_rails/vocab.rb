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

    class << self
      def app_vocabulary(key)
        vocabulary = send(key)

        LinkedRails::Vocab.define_singleton_method :app do
          vocabulary
        end
      end

      def define_shortcut(key)
        define_singleton_method(key) do
          options = RDF::Vocabulary.vocab_map.fetch(key)
          options[:class] || RDF::Vocabulary.from_sym(options[:class_name])
        end
      end

      def for(iri)
        key = vocab_map.keys.find { |k| iri.to_s.start_with?(k) }

        vocab_map[key] if key
      end

      def for!(iri)
        self.for(iri) || raise("No vocab found for #{iri}")
      end

      def register(key, uri)
        klass = CustomVocabulary.new(uri)
        klass.key = key.to_s.classify.upcase

        RDF::Vocabulary.register(key, uri, class: klass)
        vocab_map[uri.to_s] = klass

        define_shortcut(key)
      end

      def register_strict(klass)
        vocab_map[klass.to_s] = klass
      end

      def vocab_map
        return LinkedRails::Vocab.vocab_map unless self == LinkedRails::Vocab

        @vocab_map ||= {}
      end
    end

    RDF::Vocabulary.vocab_map.each_key do |key|
      define_shortcut(key)
    end

    register_strict(Vocab.as)
    register_strict(Vocab.dbo)
    register_strict(Vocab.foaf)
    register_strict(Vocab.owl)
    register_strict(Vocab.rdfs)
    register_strict(Vocab.rdfv)
    register_strict(Vocab.schema)
    register_strict(Vocab.sh)
    register_strict(Vocab.skos)
    register_strict(Vocab.xsd)
    register(:fhir, 'http://hl7.org/fhir/')
    register(:form, 'https://ns.ontola.io/form#')
    register(:libro, 'https://ns.ontola.io/libro/')
    register(:ld, 'http://purl.org/linked-delta/')
    register(:ll, 'http://purl.org/link-lib/')
    register(:ontola, 'https://ns.ontola.io/core#')
    register(:sp, 'http://spinrdf.org/sp#')
  end
end
