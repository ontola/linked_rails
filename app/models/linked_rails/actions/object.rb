# frozen_string_literal: true

require 'pundit'

module LinkedRails
  module Actions
    class Object
      include ActiveModel::Model
      include LinkedRails::Model

      attr_accessor :action
      alias parent action
      delegate :object, to: :action

      def form_resource_includes
        return {} if object.nil?

        includes = object.class.try(:preview_includes)&.presence || []

        (includes.is_a?(Hash) ? [includes] : includes) + (built_associations || [])
      end

      def iri
        action.object_iri
      end

      def preview_includes
        [object: form_resource_includes]
      end

      private

      def built_associations
        object
          .class
          .try(:reflect_on_all_associations)
          &.select(&method(:include_association?))
          &.map(&:name)
      end

      def include_association?(association)
        return unless object.association(association.name).loaded?

        records = object.send(association.name)
        association.collection? ? records.any?(&:new_record?) : records.new_record?
      end

      class << self
        def requested_resource(opts, user_context)
          parent_iri_with_query = [opts[:params][:parent_iri], opts[:iri].split('?').last].compact.join('?')

          super(opts.merge(params: opts[:params].merge(parent_iri: parent_iri_with_query)), user_context)
        end

        def requested_single_resource(params, user_context)
          return unless params.key?(:parent_iri)

          parent = parent_from_params!(params, user_context) if params.key?(:parent_iri)

          new(action: parent) if parent.object.anonymous_iri?
        end
      end
    end
  end
end
