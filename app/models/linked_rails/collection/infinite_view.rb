# frozen_string_literal: true

module LinkedRails
  class Collection
    class InfiniteView < LinkedRails.collection_view_class
      attr_accessor :before

      def initialize(attrs = {})
        # rubocop:disable Rails/TimeZone
        attrs[:before] = Time.parse(attrs[:before]).to_s(:db) if attrs[:before]
        # rubocop:enable Rails/TimeZone
        super
      end

      def next # rubocop:disable Metrics/AbcSize
        return if before.nil? || members.blank?

        next_before = members.last.send(sort_column)
        next_before = next_before.utc.to_s(:db) if next_before.is_a?(Time)
        iri_with_root(root_relative_iri(before: next_before)) if association_base.where(before_query(next_before)).any?
      end

      def prev; end

      def type
        :infinite
      end

      private

      def before_query(time = before)
        arel_table[sort_column].send(sort_direction, time)
      end

      def iri_opts
        {
          before: before
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
    end
  end
end
