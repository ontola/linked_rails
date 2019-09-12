# frozen_string_literal: true

module LinkedRails
  module Actions
    class ItemsController < LinkedRails.controller_parent_class
      active_response :show, :index

      private

      def action_list
        parent_resource!.action_list(user_context)
      end

      def authorize_action; end

      def collection_actions
        return [] if parent_resource!.try(:collections).blank?

        parent_resource!.collections.map do |opts|
          parent_resource.collection_for(opts[:name], user_context: user_context).actions(user_context)
        end.flatten
      end

      def index_association
        action_list.actions + collection_actions
      end

      def index_includes
        action_form_includes
      end

      def index_meta
        parent_triples + removed_triples + index_type_triple
      end

      def index_type_triple
        [
          [parent_resource!.actions_iri, RDF[:type], NS::LL[:LoadingResource]]
        ]
      end

      def parent_triples
        index_association.map(&method(:triples_for_action)).flatten(1)
      end

      def triples_for_action(action)
        [
          action.predicate,
          action.available? ? NS::SCHEMA[:potentialAction] : nil,
          action.available? && action.favorite ? NS::ONTOLA[:favoriteAction] : nil
        ].compact.map { |predicate| [parent_resource!.iri, predicate, action.iri, NS::ONTOLA[:replace]] }
      end

      def removed_triples
        parent_resource!.action_triples(NS::ONTOLA[:remove])
      end

      def show_includes
        action_form_includes
      end

      def redirect_action?
        parent_resource.nil? && resource_id == 'redirect'
      end

      def redirect_action # rubocop:disable Metrics/AbcSize
        resource = LinkedRails.actions_item_class.new(
          http_method: :get, type: NS::SCHEMA[:Action],
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
