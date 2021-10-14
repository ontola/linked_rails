# frozen_string_literal: true

module LinkedRails
  class Collection
    class PaginatedView < LinkedRails.collection_view_class
      include LinkedRails::Collection::Paginated
    end
  end
end
