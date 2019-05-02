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
          @actions ||= {}
          @actions[user_context] ||= action_list.actions
        end

        def action(tag, user_context = nil)
          actions(user_context).find { |a| a.tag == tag }
        end

        def build_child(klass)
          klass.new
        end

        private

        def action_list
          self.class.action_list.new(resource: self)
        end

        module ClassMethods
          def action_list
            @action_list ||= defined_action_list || define_action_list
          end

          private

          def action_superclass
            superclass.try(:action_list) || LinkedRails::Actions::List
          end

          def defined_action_list
            application_action_list = name == 'ApplicationRecord' && 'ApplicationActionList'.safe_constantize
            application_action_list || "#{name}ActionList".safe_constantize || "#{name}::ActionList".safe_constantize
          end

          def define_action_list
            const_set('ActionList', Class.new(action_superclass))
          end

          def preview_includes
            super + [favorite_actions: :target]
          end
        end
      end
    end
  end
end
