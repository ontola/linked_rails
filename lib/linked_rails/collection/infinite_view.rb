# frozen_string_literal: true

module LinkedRails
  class Collection
    class InfiniteView < LinkedRails.view_class
      attr_accessor :before

      def initialize(attrs = {})
        # rubocop:disable Rails/TimeZone
        attrs[:before] = Time.parse(attrs[:before]).to_s(:db) if attrs[:before]
        # rubocop:enable Rails/TimeZone
        super
      end

      def first
        iri(iri_opts.merge(before: Time.current.utc.to_s(:db)))
      end

      def last; end

      def next
        return if before.nil? || members.blank?

        next_before = members.last.send(sort_column)
        next_before = next_before.utc.to_s(:db) if next_before.is_a?(Time)
        iri(iri_opts.merge(before: next_before))
      end

      def prev; end

      def type
        :infinite
      end

      private

      def before_query
        arel_table[sort_column].send(sort_direction, before)
      end

      def iri_opts
        {
          before: before,
          page_size: page_size
        }.merge(collection.iri_opts)
      end

      def raw_members
        @raw_members ||=
          prepare_members(association_base)
            .where(before_query)
            .limit(page_size)
            .to_a
      end

      def sort_column
        @sort_column ||= collection.sortings.last.sort_value.keys.first
      end

      def sort_direction
        @sort_direction ||= collection.sortings.last.sort_value.values.first == :desc ? :lt : :gt
      end
    end
  end
end
