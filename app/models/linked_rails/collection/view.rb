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
      delegate :association_base, :association_class, :default_page_size, :parent, :policy, :user_context, :apply_scope,
               :display, :unfiltered_collection, :sort_direction, :total_page_count, to: :collection
      delegate :count, to: :members

      def root_relative_canonical_iri(opts = {})
        collection.unfiltered.root_relative_canonical_iri(iri_opts.merge(opts))
      end

      def root_relative_iri(opts = {})
        collection.unfiltered.root_relative_iri(iri_opts.merge(opts))
      end

      def member_sequence
        @member_sequence ||= LinkedRails::Sequence.new(members, id: members_iri)
      end

      def members
        preload_included_associations if preload_included_associations?
        @members ||= raw_members
      end

      def members_iri
        uri = iri.dup
        uri.fragment = :members
        uri
      end

      def page_size
        collection.page_size&.to_i || default_page_size
      end

      def title
        plural = association_class.name.tableize
        I18n.t("#{plural}.collection.#{filter&.values&.join('.').presence || name}",
               count: ->(_opts) { total_count },
               default: I18n.t("#{plural}.plural",
                               default: plural.humanize))
      end

      private

      def arel_table
        @arel_table ||= association_class.arel_table
      end

      def prepare_members(scope)
        if scope.respond_to?(:preload) && include_map.present?
          scope = scope.preload(association_class.includes_for_serializer)
        end
        scope
      end

      class << self
        def iri
          [super, RDF::Vocab::AS.CollectionPage]
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
