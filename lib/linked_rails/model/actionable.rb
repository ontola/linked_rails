# frozen_string_literal: true

module LinkedRails
  module Model
    module Actionable
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

      def action_triples
        @action_triples ||= triples_for_actions(actions) + triples_for_actions(collection_actions)
      end

      def collection_actions
        (try(:collections) || []).map do |opts|
          collection_for(opts[:name]).actions
        end.flatten
      end

      def favorite_actions
        actions.filter(&:favorite)
      end

      private

      def triples_for_actions(actions)
        actions.flat_map do |action|
          [
            [iri, action.predicate, action.iri],
            [iri, Vocab.schema.potentialAction, action.iri]
          ]
        end
      end

      module ClassMethods
        def action_list
          return @action_list if @action_list.try(:actionable_class) == self

          @action_list = defined_action_list || define_action_list
        end

        private

        def action_superclass
          superclass.try(:action_list) || LinkedRails.action_list_parent_class
        end

        def defined_action_list
          'ActionList'.safe_constantize
        end

        def define_action_list
          const_set('ActionList', Class.new(action_superclass))
        end
      end
    end
  end
end
