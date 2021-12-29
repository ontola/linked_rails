# frozen_string_literal: true

module LinkedRails
  class Collection
    class View
      include ActiveModel::Model

      include LinkedRails::Model

      attr_accessor :collection, :filter
      delegate :apply_scope, :association_base, :association_class, :default_page_size, :display,
               :parent, :policy, :total_page_count, :unfiltered_collection, :user_context, to: :collection
      delegate :count, to: :members

      alias id iri

      def root_relative_iri(**opts)
        collection.unfiltered.root_relative_iri(**iri_opts.merge(opts))
      end

      def member_sequence
        @member_sequence ||= LinkedRails::Sequence.new(
          members,
          id: members_iri,
          parent: self,
          scope: false
        )
      end

      def members
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

      def preview_includes
        return {member_sequence: {}} unless include_members

        {member_sequence: {members: association_class.preview_includes}}
      end

      def title
        plural = association_class.name.tableize
        I18n.t(
          "#{plural}.collection.#{filter&.values&.join('.').presence || name}",
          count: ->(_opts) { total_count },
          default: association_class.plural_label
        )
      end

      private

      def arel_table
        @arel_table ||= association_class.arel_table
      end

      def prepare_members(scope)
        if scope.respond_to?(:preload) && association_class.try(:includes_for_serializer)
          scope = scope.preload(association_class.includes_for_serializer)
        end
        scope
      end

      def raw_members
        @raw_members ||= members_query.to_a
      end

      class << self
        def iri
          [super, Vocab.as.CollectionPage]
        end

        def new(**opts)
          type = opts.delete(:type)&.to_sym
          return super if type.nil?

          case type
          when :paginated
            collection_paginated_view_class.new(**opts)
          when :infinite
            collection_infinite_view_class.new(**opts)
          else
            raise ActionController::BadRequest, "'#{type}' is not a valid collection type"
          end
        end

        def policy_class
          LinkedRails::Collection::ViewPolicy
        end

        private

        def collection_paginated_view_class
          LinkedRails.collection_paginated_view_class
        end

        def collection_infinite_view_class
          LinkedRails.collection_infinite_view_class
        end
      end
    end
  end
end
