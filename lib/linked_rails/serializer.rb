# frozen_string_literal: true

require_relative 'serializer/actionable'
require_relative 'serializer/menuable'
require_relative 'serializer/singularable'

module LinkedRails
  module Serializer
    extend ActiveSupport::Concern

    included do
      include RDF::Serializers::ObjectSerializer
      include Serializer::Actionable
      include Serializer::Menuable
      include Serializer::Singularable

      extend Enhanceable

      enhanceable :serializable_class, :Serializer

      class_attribute :_enums

      set_id :iri

      attribute :rdf_type, predicate: Vocab.rdfv.type, datatype: Vocab.xsd.anyURI
      attribute :created_at, predicate: Vocab.schema.dateCreated do |object|
        object.try(:created_at)
      end
    end

    module ClassMethods
      def anonymous_object?(object)
        object.iri.anonymous?
      end

      def enum(attr, opts = nil)
        self._enums ||= HashWithIndifferentAccess.new
        opts[:type] ||= Vocab.ontola[:FormOption]
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

      def has_one(key, **opts)
        opts[:id_method_name] = :iri

        return super if block_given?

        super do |object|
          object.send(key)
        end
      end

      def has_many(key, **opts)
        opts[:id_method_name] = :iri

        return super if block_given?

        super do |object|
          object.send(key)
        end
      end

      def named_object?(object)
        !object.iri.anonymous?
      end

      def never(_object, _params)
        false
      end

      def secret_attribute(key, **opts)
        opts[:if] = method(:never)
        attribute(key, **opts)
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

      def with_collection(name, **opts) # rubocop:disable Metrics/AbcSize
        collection_name = "#{name.to_s.singularize}_collection"
        opts[:association] ||= name
        opts[:polymorphic] ||= true
        opts[:if] ||= method(:named_object?)

        collection_opts = {}
        collection_opts[:page_size] = opts.delete(:page_size) if opts.key?(:page_size)
        collection_opts[:display] = opts.delete(:display) if opts.key?(:display)
        collection_opts[:table_type] = opts.delete(:table_type) if opts.key?(:table_type)

        has_one collection_name, **opts do |object, params|
          object.send(collection_name, **collection_opts.merge(user_context: params[:scope]))
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
