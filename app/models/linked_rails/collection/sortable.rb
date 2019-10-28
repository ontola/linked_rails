# frozen_string_literal: true

module LinkedRails
  class Collection
    module Sortable
      attr_accessor :sort
      attr_writer :default_sortings

      def default_before_value
        (sort_direction == :lt ? Time.current.utc : Time.new(1970, 1, 1).utc).iso8601(6)
      end

      def default_sortings
        opts =
          @default_sortings ||
          association_class.try(:default_sortings) ||
          [{key: RDF::Vocab::SCHEMA.dateCreated, direction: :desc}]
        opts.respond_to?(:call) ? opts.call(parent) : opts
      end

      def sort_direction
        @sort_direction ||= sortings.last.sort_value.values.first == :desc ? :lt : :gt
      end

      def sorted?
        sort.present?
      end

      def sortings
        @sortings ||=
          LinkedRails.collection_sorting_class.from_array(association_class, sort || default_sortings)
      end
    end
  end
end
