# frozen_string_literal: true

module LinkedRails
  class Collection
    class PaginatedView < LinkedRails.collection_view_class
      attr_accessor :page

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

      def prepare_members(scope)
        return super unless scope.is_a?(Array)

        Kaminari.paginate_array(super)
      end

      def raw_members
        @raw_members ||=
          prepare_members(association_base)
            .page(page)
            .per(page_size)
            .to_a
      end
    end
  end
end
