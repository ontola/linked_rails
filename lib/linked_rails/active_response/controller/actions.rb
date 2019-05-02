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
