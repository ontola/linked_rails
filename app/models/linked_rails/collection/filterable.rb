# frozen_string_literal: true

module LinkedRails
  class Collection
    module Filterable
      attr_accessor :default_filters, :filter
      attr_writer :unfiltered_collection

      def default_filtered_collections
        return if filtered? || default_filters.blank?

        @default_filtered_collections ||= default_filters.map { |filter| unfiltered.new_child(filter: filter) }
      end

      def filtered?
        filter.present?
      end

      def filters
        @filters ||= filter&.map do |key, value|
          LinkedRails.collection_filter_class.new(
            key: key,
            value: value
          )
        end
      end

      def unfiltered
        filtered? ? unfiltered_collection : self
      end

      def unfiltered_collection
        @unfiltered_collection ||= new_child(filter: [])
      end

      private

      def apply_filters(scope)
        (filter || []).reduce(scope) do |s, f|
          options = association_class.filter_options.fetch(f[0])
          apply_filter(s, filter_key(options, f[0]), filter_value(options, f[1]))
        end
      end

      def apply_filter(scope, key, value)
        case value
        when 'NULL'
          scope.where(key => nil)
        when 'NOT NULL'
          scope.where.not(key => nil)
        else
          scope.where(key => value)
        end
      end

      def filtered_association # rubocop:disable Metrics/AbcSize
        scope = association && parent&.send(association) || association_class.all
        scope = scope.send(association_scope) if association_scope
        scope = scope.joins(joins) if joins
        scope = apply_filters(scope) if filtered?
        scope
      end

      def filter_key(options, key)
        options[:key] || key
      end

      def filter_value(options, value)
        options[:values].try(:[], value.try(:to_sym)) || value
      end
    end
  end
end
