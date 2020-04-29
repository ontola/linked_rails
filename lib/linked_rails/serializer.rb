# frozen_string_literal: true

module LinkedRails
  module Serializer
    extend ActiveSupport::Concern

    included do
      extend Enhanceable

      enhanceable :serializable_class, :Serializer

      class_attribute :_enums

      set_id :iri

      attribute :rdf_type, predicate: RDF[:type], datatype: RDF::XSD[:anyURI]
      attribute :canonical_iri, predicate: RDF::Vocab::DC[:identifier] do |object|
        object.try(:canonical_iri) || object.iri
      end
    end

    module ClassMethods
      def enum(key, opts = nil)
        self._enums ||= {}
        self._enums[key] = opts.except(:if, :predicate).presence
        enum_opts = enum_options(key).try(:[], :options)

        attribute(key, if: opts[:if], predicate: opts[:predicate]) do |object|
          enum_value(key, enum_opts, object) if enum_opts
        end
      end

      def enum_options(key)
        _enums && _enums[key] || default_enum_opts(key, serializable_class.try(:defined_enums).try(:[], key.to_s))
      end

      def enum_value(key, enum_opts, object)
        raw_value = object.send(key)

        enum_opts[raw_value&.to_sym].try(:[], :iri) if raw_value.present?
      end

      def default_enum_opts(key, enum_opts)
        return if enum_opts.blank?

        {
          type: Vocab::ONTOLA[:FormOption],
          options: Hash[
            enum_opts&.map { |k, _v| [k.to_sym, {iri: Vocab::ONTOLA["form_option/#{key}/#{k}"]}] }
          ]
        }
      end

      # rubocop:disable Naming/PredicateName
      def has_one(key, opts = {})
        opts[:id_method_name] = :iri

        return super if block_given?

        super do |object|
          object.send(key)
        end
      end

      def has_many(key, opts = {})
        opts[:id_method_name] = :iri

        return super if block_given?

        super do |object|
          object.send(key)
        end
      end
      # rubocop:enable Naming/PredicateName

      def serializable_class
        @serializable_class ||= name.gsub('Serializer', '').safe_constantize
      end

      def serialize_image(obj)
        if obj.is_a?(String) || obj.is_a?(Symbol)
          RDF::URI(obj.to_s.gsub(/^fa-/, 'http://fontawesome.io/icon/'))
        else
          obj.presence
        end
      end

      def with_collection(name, opts = {})
        collection_name = "#{name.to_s.singularize}_collection"
        page_size = opts.delete(:page_size)
        display = opts.delete(:display)

        has_one collection_name, opts.merge(association: name, polymorphic: true) do |object, params|
          object.send(collection_name, user_context: params[:scope], display: display, page_size: page_size)
        end
      end
    end
  end
end
