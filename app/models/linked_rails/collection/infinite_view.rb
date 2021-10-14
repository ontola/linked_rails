# frozen_string_literal: true

module LinkedRails
  class Collection
    class InfiniteView < LinkedRails.collection_view_class
      include LinkedRails::Collection::Infinite
    end
  end
end
