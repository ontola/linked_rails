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

      def iri
        action.object_iri
      end

      class << self
        def requested_resource(opts, user_context)
          return super unless opts[:iri].include?('?')

          parent_iri_with_query = [opts[:params][:parent_iri], opts[:iri].split('?').last].compact.join('?')

          super(opts.merge(params: opts[:params].merge(parent_iri: parent_iri_with_query)), user_context)
        end

        def requested_single_resource(params, user_context)
          return unless params.key?(:parent_iri)

          parent = parent_from_params!(params, user_context)

          new(action: parent) if parent.object.anonymous_iri?
        end
      end
    end
  end
end
