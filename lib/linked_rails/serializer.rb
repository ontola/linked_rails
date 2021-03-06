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
        object.try(:canonical_iri)
      end
    end

    module ClassMethods
      def anonymous_object?(object)
        object.iri.anonymous?
      end

      def enum(attr, opts = nil)
        self._enums ||= HashWithIndifferentAccess.new
        opts[:type] ||= Vocab::ONTOLA[:FormOption]
        opts[:options] ||= default_enum_opts(attr)
        self._enums[attr] = enum_values(attr, opts)

        attribute(attr, if: opts[:if], predicate: opts[:predicate]) do |object, params|
          block_given? ? yield(object, params) : enum_value(attr, object)
        end
      end

      def enum_options(key)
        _enums && _enums[key]
      end

      def enum_value(key, object)
        options = enum_options(key)
        return if options.blank?

        raw_value = object.send(key)

        options[raw_value].try(:iri) if raw_value.present?
      end

      def default_enum_opts(attr)
        enum_opts = serializable_class.try(:defined_enums).try(:[], attr.to_s)
        return [] if enum_opts.blank?

        HashWithIndifferentAccess[
          enum_opts&.map { |k, _v| [k.to_sym, {}] }
        ]
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

      def named_object?(object)
        !object.iri.anonymous?
      end

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
        opts[:association] ||= name
        opts[:polymorphic] ||= true
        opts[:if] ||= method(:named_object?)

        has_one collection_name, opts do |object, params|
          object.send(collection_name, user_context: params[:scope], display: display, page_size: page_size)
        end
      end

      private

      def enum_values(attr, opts) # rubocop:disable Metrics/MethodLength
        Hash[
          opts[:options].map do |option_key, option_values|
            [
              option_key,
              LinkedRails::EnumValue.new(
                {
                  key: option_key,
                  attr: attr,
                  klass: serializable_class,
                  type: opts[:type]
                }.merge(option_values)
              )
            ]
          end
        ]
      end
    end
  end
end
