# frozen_string_literal: true

module LinkedRails
  module ActiveResponse
    module Controller
      module CrudDefaults
        private

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

        def destroy_success_options_rdf
          opts = destroy_success_options
          opts[:meta] = destroy_meta
          opts
        end

        def destroy_meta
          resource_removed_delta(current_resource)
        end

        def preview_includes
          controller_class.try(:preview_includes)
        end

        def requested_resource
          @requested_resource ||= controller_class.try(
            :requested_resource,
            LinkedRails.iri_mapper.route_params_to_opts(params.dup),
            user_context
          )
        end

        def requested_resource!
          requested_resource || raise(ActiveRecord::RecordNotFound)
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
