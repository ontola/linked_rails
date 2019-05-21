# frozen_string_literal: true

module LinkedRails
  module ActiveResponse
    module Controller
      module CrudDefaults
        def create_success_options_rdf
          opts = create_success_options
          opts[:meta] = create_meta
          opts
        end

        def create_meta
          invalidate_parent_collections
        end

        def default_form_options(action)
          return super unless active_responder.is_a?(RDFResponder)

          action = ld_action(super.slice(:resource, :view))
          {
            action: action || raise("No action found for #{action_name}"),
            include: action_form_includes(action)
          }
        end

        def destroy_success_options_rdf
          opts = destroy_success_options
          opts[:meta] = destroy_meta
          opts
        end

        def destroy_meta
          invalidate_parent_collections
        end

        def index_success_options_rdf
          return index_success_options if index_collection_or_view.nil?

          {
            collection: index_collection_or_view,
            include: index_includes_collection,
            locals: index_locals,
            meta: request.head? ? [] : index_meta
          }
        end

        def invalidate_parent_collections
          data = []
          current_resource.parent_collections.each do |collection|
            data.push [NS::SP[:Variable], NS::ONTOLA[:baseCollection], collection.iri, NS::ONTOLA[:invalidate]]
          end
          data
        end

        def permit_params
          @permit_params ||=
            params
              .require(controller_name.singularize)
              .permit(*policy(current_resource).permitted_attributes)
        end

        def show_success_options_rdf
          opts = show_success_options.except(:locals)
          opts[:meta] = request.head? ? [] : show_meta
          opts
        end

        def show_meta
          []
        end

        def update_success_options_rdf
          opts = update_success_options
          opts[:meta] = update_meta
          opts
        end

        def update_meta
          []
        end

        def user_context
          current_user
        end
      end
    end
  end
end
