# frozen_string_literal: true

module LinkedRails
  module Actions
    class ItemsController < LinkedRails.controller_parent_class
      active_response :show, :index

      private

      def action_list
        parent_resource!.action_list(user_context)
      end

      def actions
        @actions ||= action_list.actions + collection_actions
      end

      def authorize_action; end

      def collection_actions
        return [] if parent_resource!.try(:collections).blank?

        parent_resource!.collections.map do |opts|
          parent_resource.collection_for(opts[:name], user_context: user_context).actions(user_context)
        end.flatten
      end

      def index_association
        actions.reject(&:exclude)
      end

      def index_includes
        action_form_includes
      end

      def index_meta
        actions.map(&method(:triples_for_action)).flatten(1) + removed_triples
      end

      def triples_for_action(action)
        [
          action.available? ? RDF::Vocab::SCHEMA.potentialAction : nil,
          action.available? && action.favorite ? Vocab::ONTOLA[:favoriteAction] : nil
        ].compact.map { |predicate| [parent_resource!.iri, predicate, action.iri, delta_iri(:replace)] }
      end

      def removed_triples
        %i[potentialAction favoriteAction].map do |type|
          [parent_resource!.iri, Vocab::ONTOLA[type], parent_resource!.actions_iri(type), delta_iri(:remove)]
        end
      end

      def show_includes
        action_form_includes
      end

      def redirect_action?
        parent_resource.nil? && resource_id == 'redirect'
      end

      def redirect_action # rubocop:disable Metrics/AbcSize
        resource = LinkedRails.actions_item_class.new(
          http_method: :get, type: RDF::Vocab::SCHEMA.Action,
          label: params[:label],
          target: {id: RDF::URI(params[:location])}
        )
        resource.instance_variable_set(:@canonical_iri, RDF::URI(request.original_url))
        resource.instance_variable_set(:@iri, RDF::URI(request.original_url))
        resource
      end

      def requested_resource
        @requested_resource ||= redirect_action? ? redirect_action : action_list.action(params[:id].to_sym)
      end
    end
  end
end
