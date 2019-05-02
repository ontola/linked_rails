# frozen_string_literal: true

require_relative 'preloading'

module LinkedRails
  class Collection
    class View
      include ActiveModel::Serialization
      include ActiveModel::Model

      include LinkedRails::Model
      include LinkedRails::Collection::Preloading

      attr_accessor :collection, :filter, :include_map
      attr_writer :page_size
      delegate :association_base, :association_class, :default_page_size, :parent, :policy, :user_context, :apply_scope,
               :display, :unfiltered_collection, to: :collection
      delegate :count, to: :members

      def iri_path(opts = {})
        collection.unfiltered.iri_template.expand(iri_opts.merge(opts))
      end

      def member_sequence
        @member_sequence ||= LinkedRails::Sequence.new(members)
      end

      def members
        preload_included_associations if preload_included_associations?
        @members ||= raw_members
      end

      def page_size
        @page_size&.to_i || default_page_size
      end

      def title
        plural = association_class.name.tableize
        I18n.t("#{plural}.collection.#{filter&.values&.join('.').presence || name}",
               count: total_count,
               default: I18n.t("#{plural}.plural",
                               default: plural.humanize))
      end

      private

      def arel_table
        @arel_table ||= Arel::Table.new(association_table)
      end

      def association_table
        parent&.class.try(:reflect_on_association, collection.association)&.table_name ||
          association_class.to_s.tableize
      end

      def base_count
        collection.total_count
      end

      def parsed_sort_values
        collection.sortings.map(&:sort_value)
      end

      def prepare_members(scope)
        scope = scope.preload(association_class.includes_for_serializer) if scope.respond_to?(:preload)
        scope = scope.reorder(parsed_sort_values) if scope.respond_to?(:reorder)
        scope
      end

      def total_page_count
        (base_count / page_size.to_f).ceil if base_count
      end

      class << self
        def iri
          [super, NS::AS['CollectionPage']]
        end

        def new(opts = {})
          type = opts.delete(:type)&.to_sym
          return super if type.nil?

          case type
          when :paginated
            LinkedRails.collection_paginated_view_class.new(opts)
          when :infinite
            LinkedRails.collection_infinite_view_class.new(opts)
          else
            raise ActionController::BadRequest, "'#{type}' is not a valid collection type"
          end
        end
      end
    end
  end
end
