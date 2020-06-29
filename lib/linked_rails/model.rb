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

    def build_child(klass, _opts = {})
      klass.new
    end

    module ClassMethods
      def build_new(opts = {})
        new(attribute_for_new(opts))
      end

      def form_class
        @form_class ||= "#{name}Form".safe_constantize
      end

      private

      def attribute_for_new(_opts)
        {}
      end
    end
  end
end
