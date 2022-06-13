# frozen_string_literal: true

require_relative 'model/actionable'
require_relative 'model/collections'
require_relative 'model/dirty'
require_relative 'model/enhancements'
require_relative 'model/filtering'
require_relative 'model/indexable'
require_relative 'model/iri'
require_relative 'model/iri_mapping'
require_relative 'model/menuable'
require_relative 'model/serialization'
require_relative 'model/singularable'
require_relative 'model/sorting'
require_relative 'model/tables'

module LinkedRails
  module Model
    extend ActiveSupport::Concern
    include Actionable
    include Collections
    include Dirty
    include Enhancements
    include Filtering
    include Indexable
    include IRI
    include IRIMapping
    include Menuable
    include Serialization
    include Singularable
    include Sorting
    include Tables

    def build_child(klass, user_context: nil)
      klass.build_new(parent: self, user_context: user_context)
    end

    module ClassMethods
      def build_new(parent: nil, user_context: nil)
        raise(ActiveRecord::RecordNotFound) if try(:abstract_class?)

        new(**attributes_for_new(parent: parent, user_context: user_context))
      end

      def controller_class
        @controller_class ||= "#{to_s.pluralize}Controller".safe_constantize || superclass.try(:controller_class)
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
