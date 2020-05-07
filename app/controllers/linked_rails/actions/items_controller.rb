# frozen_string_literal: true

module LinkedRails
  module Actions
    class ItemsController < LinkedRails.controller_parent_class
      active_response :show, :index

      private

      def actions
        @actions ||= parent_resource!.actions(user_context) + parent_resource!.collection_actions(user_context)
      end

      def authorize_action; end

      def index_association
        actions.reject(&:exclude)
      end

      def index_includes
        action_form_includes
      end

      def index_meta
        parent_resource!.potential_and_favorite_triples(user_context)
      end

      def show_includes
        action_form_includes
      end

      def redirect_action?
        parent_resource.nil? && resource_id == 'redirect'
      end

      def redirect_action # rubocop:disable Metrics/AbcSize
        resource = LinkedRails.actions_item_class.new(
          http_method: :get,
          type: RDF::Vocab::SCHEMA.Action,
          label: params[:label],
          target: {id: RDF::URI(params[:location])}
        )
        resource.instance_variable_set(:@canonical_iri, RDF::URI(request.original_url))
        resource.instance_variable_set(:@iri, RDF::URI(request.original_url))
        resource
      end

      def requested_resource
        @requested_resource ||=
          if redirect_action?
            redirect_action
          else
            parent_resource!.action(params[:id]&.to_sym, user_context)
          end
      end
    end
  end
end
