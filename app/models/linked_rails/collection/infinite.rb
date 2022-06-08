# frozen_string_literal: true

module LinkedRails
  class Collection
    module Infinite
      extend ActiveSupport::Concern

      included do
        attr_accessor :before
      end

      def any?
        return members_query.any? if members_query.is_a?(ActiveRecord::Relation)

        count.positive?
      end

      def initialize(orignial = {})
        attrs = orignial.with_indifferent_access
        attrs[:before] = attrs[:before]&.map { |val| val.with_indifferent_access }
        super(attrs)
      end

      def next
        return if before.blank? || members.blank?

        current_opts = {
          collection: collection,
          filter: filter
        }
        next_view = collection.view_with_opts(current_opts.merge(before: next_before_values))

        next_view.iri if next_view.any?
      end

      def prev; end

      def type
        :infinite
      end

      private

      def additional_statements(arel, index)
        (preconditions(index) + [arel]).reduce { |or_acc, or_value| or_acc.and(or_value) }
      end

      def before_iri_opts
        before&.map { |hash| "#{CGI.escape(hash[:key])}=#{hash[:value]}" }
      end

      def before_query
        before_values.each_with_index.reduce(nil) do |acc, (value, index)|
          arel = arel_table[value[:attribute]].send(value[:direction], value[:value])
          acc.nil? ? arel : acc.or(additional_statements(arel, index))
        end
      end

      def before_values
        @before_values ||= before&.map do |value|
          sorting = collection.sortings.detect { |s| s.key == value[:key] }
          {
            attribute: sorting.attribute_name,
            direction: sorting.sort_direction,
            key: value[:key],
            value: value[:value]
          }
        end
      end

      def iri_opts
        {
          'before%5B%5D': before_iri_opts
        }.merge(collection.iri_opts)
      end

      def iris_from_scope; end

      def members_query
        @members_query ||=
          prepare_members(association_base)
            .where(before_query)
            .limit(page_size)
      end

      def next_before_values
        last_record = members_query.last
        before_values.map do |val|
          value = last_record.send(val[:attribute])
          value = value.utc.iso8601(6) if value.is_a?(Time)
          {
            key: val[:key],
            value: value
          }
        end
      end

      def preconditions(index)
        before_values[0...index].map do |v|
          condition = arel_table[v[:attribute]].eq(v[:value])
          condition = condition.or(arel_table[v[:attribute]].eq(nil)) if v[:direction] == :gt
          condition
        end
      end

      def sort_column
        @sort_column ||= collection.sortings.last.sort_value.keys.first
      end
    end
  end
end
