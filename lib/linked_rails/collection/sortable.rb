# frozen_string_literal: true

module LinkedRails
  class Collection
    module Sortable
      attr_accessor :sort
      attr_writer :default_sortings

      def default_sortings
        opts =
          @default_sortings ||
          association_class.try(:default_sortings) ||
          [{key: NS::SCHEMA[:dateCreated], direction: :desc}]
        opts.respond_to?(:call) ? opts.call(parent) : opts
      end

      def sorted?
        sort.present?
      end

      def sortings
        @sortings ||=
          LinkedRails.sorting_class.from_array(association_class, sort || default_sortings)
      end
    end
  end
end
