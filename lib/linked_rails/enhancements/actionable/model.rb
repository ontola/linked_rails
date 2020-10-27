# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Actionable
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

        def action_triples # rubocop:disable Metrics/AbcSize
          (actions + collection_actions).map do |action|
            [
              [iri, action.predicate, action.iri],
              [iri, RDF::Vocab::SCHEMA.potentialAction, action.iri],
              action.favorite ? [iri, LinkedRails::Vocab::ONTOLA[:favoriteAction], action.iri] : nil
            ]
          end.flatten(1).compact
        end

        def actions_iri(tag)
          actions_iri = iri_with_root(RDF::URI(iri_template_expand_path(iri_template, '/actions').expand(iri_opts)))
          actions_iri.fragment = tag if tag.present?
          actions_iri
        end

        def collection_actions
          (try(:collections) || []).map do |opts|
            collection_for(opts[:name]).actions
          end.flatten
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
            "#{name}ActionList".safe_constantize
          end

          def define_action_list
            list = const_set("#{name.demodulize}ActionList", Class.new(action_superclass))
            list.include_enhancements(:actionable_class, :Action)
            list
          end
        end
      end
    end
  end
end
