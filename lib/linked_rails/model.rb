# frozen_string_literal: true

require_relative 'model/collections'
require_relative 'model/dirty'
require_relative 'model/enhancements'
require_relative 'model/filtering'
require_relative 'model/iri'
require_relative 'model/serialization'
require_relative 'model/sorting'

module LinkedRails
  module Model
    extend ActiveSupport::Concern
    include Collections
    include Dirty
    include Enhancements
    include Filtering
    include Iri
    include Serialization
    include Sorting

    def build_child(klass)
      klass.new
    end
  end
end
