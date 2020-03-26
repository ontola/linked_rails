# frozen_string_literal: true

module LinkedRails
  class Collection
    module Sortable
      attr_accessor :sort
      attr_writer :default_sortings

      def default_before_value
        sortings.map do |sorting|
          {
            key: sorting.key,
            value: sorting.default_value
          }
        end
      end

      def default_sortings
        opts =
          @default_sortings ||
          association_class.try(:default_sortings) ||
          [{key: RDF::Vocab::SCHEMA.dateCreated, direction: :desc}]
        opts.respond_to?(:call) ? opts.call(parent) : opts
      end

      def parsed_sort_values
        sortings.map(&:sort_value)
      end

      def primary_key_sorting
        [
          {
            key: Vocab::ONTOLA[:primaryKey],
            direction: :asc
          }
        ]
      end

      def sorted_association(scope)
        scope.respond_to?(:reorder) ? scope.reorder(parsed_sort_values) : scope
      end

      def sorted?
        sort.present?
      end

      def sortings
        @sortings ||= LinkedRails.collection_sorting_class.from_array(
          association_class,
          (sort || default_sortings) + primary_key_sorting
        )
      end
    end
  end
end
