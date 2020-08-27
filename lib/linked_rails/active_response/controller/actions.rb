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

        def form_resource_includes(action)
          included_object = action&.included_object

          return {} if included_object.nil? || included_object.anonymous_iri?

          includes = included_object.class.try(:show_includes)&.presence || []
          includes = [includes] if includes.is_a?(Hash)
          if action.resource.is_a?(LinkedRails.collection_class)
            includes << [:filters, :sortings, filter_fields: :options]
          end
          includes
        end

        def ld_action(resource:, view:)
          action_resource = resource.try(:new_record?) && index_collection || resource
          action_resource.action(ld_action_name(view), user_context)
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
