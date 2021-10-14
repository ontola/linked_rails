# frozen_string_literal: true

module LinkedRails
  class Collection
    module Paginated
      extend ActiveSupport::Concern

      included do
        attr_accessor :page
      end

      def next
        return if page.nil? || page.to_i >= (total_page_count || 0)

        iri_with_root(root_relative_iri(page: page.to_i + 1))
      end

      def prev
        return if page.nil? || page.to_i <= 1

        iri_with_root(root_relative_iri(page: page.to_i - 1))
      end

      private

      def iri_opts
        {
          page: page
        }.merge(collection.iri_opts)
      end

      def members_query
        prepare_members(association_base)
          .page(page)
          .per(page_size)
      end

      def prepare_members(scope)
        return super unless scope.is_a?(Array) && !scope.is_a?(Kaminari::PaginatableArray)

        Kaminari.paginate_array(super)
      end
    end
  end
end
