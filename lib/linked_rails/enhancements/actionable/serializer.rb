# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Actionable
      module Serializer
        extend ActiveSupport::Concern

        included do
          has_many :actions,
                   key: :operation,
                   predicate: NS::SCHEMA[:potentialAction]
          has_many :favorite_actions,
                   predicate: LinkedRails::NS::ONTOLA[:favoriteAction]
          triples :action_methods
        end

        def actions
          object_actions + collection_actions
        end

        def action_methods
          triples = []
          actions&.each { |action| triples.append(action_triples(action)) }
          triples
        end

        def favorite_actions
          actions&.select(&:favorite)
        end

        private

        def action_triples(action)
          action_triple(object, LinkedRails::NS::ONTOLA["#{action.tag}_action".camelize(:lower)], action.iri)
        end

        def action_triple(subject, predicate, iri)
          subject_iri = subject.iri
          subject_iri = RDF::URI(subject_iri.to_s.sub('/lr/', '/od/')) if subject.class.to_s == 'LinkedRecord'
          [subject_iri, predicate, iri]
        end

        def collection_actions
          return [] if object.collections.blank?

          object.collections.map do |opts|
            object.collection_for(opts[:name], user_context: scope).actions(scope).select(&:available?)
          end.flatten
        end

        def object_actions
          object.actions(scope).select(&:available?)
        end
      end
    end
  end
end
