# frozen_string_literal: true

module LinkedRails
  module ActiveResponse
    module Controller
      module Actions
        ACTION_MAP = {
          edit: :update,
          bin: :trash,
          unbin: :untrash,
          delete: :destroy,
          new: :create,
          shift: :move
        }.freeze

        private

        def action_form_includes(action = nil)
          [:target, included_object: form_resource_includes(action)]
        end

        def collection_action?
          %w[new create].include?(action_name) && index_collection
        end

        def form_resource_includes(action) # rubocop:disable Metrics/CyclomaticComplexity
          included_object = action&.included_object

          return {} if included_object.nil?
          return action.include_paths || {} if included_object.iri.anonymous?

          includes = included_object.class.try(:show_includes)&.presence || []
          includes = [includes] if includes.is_a?(Hash)
          if action.resource.is_a?(LinkedRails.collection_class)
            includes << [:filters, :sortings, filter_fields: :options]
          end
          includes
        end

        def ld_action(resource:, view:)
          ld_action_resource(resource).action(ld_action_name(view), user_context)
        end

        def ld_action_resource(resource)
          collection_action? ? index_collection : resource
        end

        def ld_action_name(view)
          form = params[:form]
          form ||= view == 'form' ? action_name : view
          ACTION_MAP[form.to_sym] || form.to_sym
        end
      end
    end
  end
end
