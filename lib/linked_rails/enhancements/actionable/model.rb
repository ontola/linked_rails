# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Actionable
      FORM_INCLUDES = [
        target: {
          action_body: [
            :form_steps,
            referred_shapes: [:form_steps, property: :sh_in_options],
            property: [:sh_in_options, referred_shapes: [:form_steps, property: :sh_in_options]].freeze
          ].freeze
        }.freeze
      ].freeze

      module Model
        extend ActiveSupport::Concern

        def actions(user_context = nil)
          action_list(user_context).actions
        end

        def action(tag, user_context = nil)
          actions(user_context).find { |a| a.tag == tag }
        end

        def action_list(user_context)
          @action_list ||= {}
          @action_list[user_context] ||= self.class.action_list.new(resource: self, user_context: user_context)
        end

        module ClassMethods
          def action_list
            @action_list ||= defined_action_list || define_action_list
          end

          def preview_includes
            super + [favorite_actions: :target]
          end

          private

          def action_superclass
            superclass.try(:action_list) || 'ApplicationActionList'.safe_constantize || LinkedRails::Actions::List
          end

          def defined_action_list
            "#{name}ActionList".safe_constantize || "#{name}::ActionList".safe_constantize
          end

          def define_action_list
            list = const_set('ActionList', Class.new(action_superclass))
            list.include_enhancements(:actionable_class, :Action)
            list
          end
        end
      end
    end
  end
end
