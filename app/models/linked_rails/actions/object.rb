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

      def root_relative_iri
        action.object_root_relative_iri
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

          object = parent&.object
          object.instance_variable_set(:@iri, parent.object_iri)
          object.instance_variable_set(:@root_relative_iri, parent.object_root_relative_iri)
          object
        end
      end
    end
  end
end
