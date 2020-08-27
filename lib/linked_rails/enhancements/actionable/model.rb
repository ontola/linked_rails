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

        def action_triples(user_context) # rubocop:disable Metrics/AbcSize
          (actions(user_context) + collection_actions(user_context)).map do |action|
            [iri, action.predicate, action.iri]
          end + [
            [iri, RDF::Vocab::SCHEMA.potentialAction, actions_iri(:potentialAction)],
            [iri, LinkedRails::Vocab::ONTOLA[:favoriteAction], actions_iri(:favoriteAction)],
            [actions_iri(:potentialAction), Vocab::SP[:Variable], Vocab::SP[:Variable], Vocab::ONTOLA[:invalidate]],
            [actions_iri(:favoriteAction), Vocab::SP[:Variable], Vocab::SP[:Variable], Vocab::ONTOLA[:invalidate]]
          ]
        end

        def actions_iri(tag)
          actions_iri = iri_with_root(RDF::URI(iri_template_expand_path(iri_template, '/actions').expand(iri_opts)))
          actions_iri.fragment = tag if tag.present?
          actions_iri
        end

        def collection_actions(user_context)
          (try(:collections) || []).map do |opts|
            collection_for(opts[:name], user_context: user_context).actions(user_context)
          end.flatten
        end

        def potential_and_favorite_triples(user_context)
          remove_actions_iri_triples +
            (actions(user_context) + collection_actions(user_context))
              .map(&method(:potential_and_favorite_for_action))
              .flatten(1)
        end

        private

        def potential_and_favorite_for_action(action)
          [
            action.available? ? RDF::Vocab::SCHEMA.potentialAction : nil,
            action.favorite ? Vocab::ONTOLA[:favoriteAction] : nil
          ].compact.map { |predicate| [iri, predicate, action.iri, Vocab::ONTOLA[:replace]] }
        end

        def remove_actions_iri_triples
          [
            [iri, RDF::Vocab::SCHEMA.potentialAction, actions_iri(:potentialAction), Vocab::ONTOLA[:remove]],
            [actions_iri(:potentialAction), RDF[:type], NS::LL[:LoadingResource]],
            [iri, Vocab::ONTOLA[:favoriteAction], actions_iri(:favoriteAction), Vocab::ONTOLA[:remove]],
            [actions_iri(:favoriteAction), RDF[:type], NS::LL[:LoadingResource]]
          ]
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
