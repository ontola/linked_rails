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
          resource_added_delta(current_resource)
        end

        def current_resource_for_params
          current_resource
        end

        def default_form_options(action)
          return super unless active_responder.is_a?(RDFResponder)

          action = ld_action(**super.slice(:resource, :view))
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
          resource_removed_delta(current_resource)
        end

        def index_success_options_rdf
          {
            collection: index_sequence ? index_sequence : index_collection_or_view,
            include: index_sequence ? index_includes_sequence : index_includes_collection,
            meta: index_meta
          }
        end

        def permit_params
          @permit_params ||=
            params
              .require(permit_param_key)
              .permit(*permit_param_keys)
        end

        def permit_param_key
          controller_name.singularize
        end

        def permit_param_keys
          policy(current_resource_for_params).try(:permitted_attributes)
        end

        def preview_includes
          controller_class.try(:preview_includes)
        end

        def show_includes
          controller_class.try(:show_includes)
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
          changes_triples + changed_relations_triples
        end

        def user_context
          current_user
        end
      end
    end
  end
end
