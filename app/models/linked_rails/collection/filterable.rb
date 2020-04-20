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
        options = filter_options.fetch(key)
        values.reduce(scope) do |s, value|
          apply_filter_value(s, key, value, options)
        end
      end

      def apply_filter_value(scope, key, value, options)
        return options[:filter].call(scope, value) if options.key?(:filter)

        scope.where(association_class.predicate_mapping[key].key => value)
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
          options: options[:values].map do |option|
            attrs = option.is_a?(Hash) ? option : {value: option}
            Collection::FilterOption.new(attrs.merge(collection: self, key: key))
          end
        )
      end

      def sanitized_filter_value(key, value)
        val = xsd_to_rdf(association_class.predicate_mapping[key].datatype, value)
        val.literal? ? val.object : val
      end
    end
  end
end
