# frozen_string_literal: true

module LinkedRails
  class Collection
    module Filterable
      include RDF::Serializers::DataTypeHelper

      attr_writer :default_filters, :filter, :unfiltered_collection

      def default_filters
        opts = @default_filters || association_class.try(:default_filters) || {}
        opts.respond_to?(:call) ? opts.call(parent) : opts
      end

      def filter
        default_filters.merge(@filter || {})
      end

      delegate :filter_options, to: :association_class

      def filter_fields
        @filter_fields ||= filter_options&.map { |key, options| filter_field(key, options) }
      end

      def filtered?
        filter.present?
      end

      def filters
        @filters ||= filter.map do |key, values|
          predicate = key.is_a?(RDF::URI) ? key : association_class.predicate_for_key(key)

          LinkedRails.collection_filter_class.new(
            collection: self,
            default_filter: !@filter&.key?(predicate),
            key: predicate,
            value: values.map { |val| sanitized_filter_value(predicate, val) }
          )
        end
      end

      def unfiltered
        filtered? ? unfiltered_collection : self
      end

      def unfiltered_collection
        @unfiltered_collection ||= new_child(filter: {})
      end

      private

      def apply_filters(scope)
        (filters || []).reduce(scope) do |s, filter|
          apply_filter(s, filter.key, filter.value)
        end
      end

      def apply_filter(scope, key, values)
        filter = filter_options.fetch(key).try(:[], :filter)

        return filter.call(scope, values) if filter

        scope.where(association_class.predicate_mapping[key].key => values)
      end

      def filtered_association # rubocop:disable Metrics/AbcSize
        scope = association && parent&.send(association) || association_class.all
        scope = scope.send(association_scope) if association_scope
        scope = scope.joins(joins) if joins
        scope = apply_filters(scope) if filtered?
        scope
      end

      def filter_field(key, options)
        Collection::FilterField.new(
          collection: self,
          klass: association_class,
          key: key,
          options_in: options[:values_in],
          options_array: options[:values]
        )
      end

      def sanitized_filter_value(key, value)
        mapping = association_class.predicate_mapping[key]
        datatype = mapping.is_a?(FastJsonapi::Relationship) ? Vocab.xsd.anyURI : mapping.datatype
        val = xsd_to_rdf(datatype, value)
        val.literal? ? val.object : val
      end
    end
  end
end
