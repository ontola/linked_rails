# frozen_string_literal: true

module LinkedRails
  class Collection
    module Sortable
      attr_accessor :sort
      attr_writer :sort_options

      def default_before_value
        sortings.map do |sorting|
          {
            key: sorting.key,
            value: sorting.default_value
          }
        end
      end

      def parsed_sort_values
        sortings.map(&:sort_value)
      end

      def primary_key_sorting
        [
          {
            key: Vocab.ontola[:primaryKey],
            direction: :asc
          }
        ]
      end

      def sort_options
        @sort_options || association_class.try(:sort_options, self)
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
          (sort || default_sortings) + primary_key_sorting,
          self
        )
      end
    end
  end
end
