# frozen_string_literal: true

require_relative 'model/collections'
require_relative 'model/dirty'
require_relative 'model/enhancements'
require_relative 'model/filtering'
require_relative 'model/indexable'
require_relative 'model/iri'
require_relative 'model/iri_mapping'
require_relative 'model/serialization'
require_relative 'model/sorting'

module LinkedRails
  module Model
    extend ActiveSupport::Concern
    include Collections
    include Dirty
    include Enhancements
    include Filtering
    include Indexable
    include Iri
    include IriMapping
    include Serialization
    include Sorting

    def build_child(klass, user_context: nil)
      klass.build_new(parent: self, user_context: user_context)
    end

    def singular_resource?
      false
    end

    module ClassMethods
      def build_new(parent: nil, user_context: nil)
        new(attributes_for_new(parent: parent, user_context: user_context))
      end

      def form_class
        @form_class ||= "#{name}Form".safe_constantize || superclass.try(:form_class)
      end

      def label
        obj = iri.is_a?(Array) ? iri.first : iri
        LinkedRails.translate(:class, :label, obj) if obj
      end

      def plural_label
        obj = iri.is_a?(Array) ? iri.first : iri
        LinkedRails.translate(:class, :plural_label, obj) if obj
      end

      def policy_class
        @policy_class ||= "#{name}Policy".safe_constantize || superclass.try(:policy_class)
      end

      private

      def attribute_from_filter(filter, predicate)
        filter[predicate]&.first if filter
      end

      def attributes_for_new(_opts)
        {}
      end
    end
  end
end
