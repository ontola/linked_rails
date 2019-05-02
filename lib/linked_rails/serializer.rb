# frozen_string_literal: true

module LinkedRails
  module Serializer
    extend ActiveSupport::Concern

    included do
      extend Enhanceable

      enhanceable :serializable_class, :Serializer

      class_attribute :_enums

      attribute :type, predicate: RDF[:type]
      attribute :canonical_iri, predicate: NS::DC[:identifier]
    end

    def id
      rdf_subject
    end

    def canonical_iri
      object.try(:canonical_iri) || rdf_subject
    end

    def rdf_subject
      object.iri
    end

    def serializable_class
      self.class.serializable_class
    end

    def type
      object.class.iri
    end

    module ClassMethods
      def enum(key, opts = nil)
        self._enums ||= {}
        self._enums[key] = opts

        define_method(key) do
          self.class.enum_options(key) &&
            self.class.enum_options(key)[:options][object.send(key)&.to_sym].try(:[], :iri)
        end
      end

      def enum_options(key)
        _enums && _enums[key] || default_enum_opts(key, serializable_class.try(:defined_enums).try(:[], key.to_s))
      end

      def default_enum_opts(key, enum_opts)
        return if enum_opts.blank?

        {
          type: NS::SCHEMA[:Thing],
          options: Hash[
            enum_opts&.map { |k, _v| [k.to_sym, {iri: LinkedRails::NS::ONTOLA["form_option/#{key}/#{k}"]}] }
          ]
        }
      end

      def serializable_class
        @serializable_class ||= name.gsub('Serializer', '').safe_constantize
      end

      def with_collection(name, opts = {})
        collection_name = "#{name.to_s.singularize}_collection"
        page_size = opts.delete(:page_size)

        has_one collection_name, opts.merge(association: name)

        define_method collection_name do
          object.send(collection_name, user_context: scope, page_size: page_size)
        end
      end
    end
  end
end
