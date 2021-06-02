# frozen_string_literal: true

module LinkedRails
  module ActiveResponse
    module Controller
      module Collections
        private

        def include_collection_items?
          true
        end

        def index_association; end

        def index_collection_includes(member_includes = {})
          {
            default_view: index_collection_view_includes(member_includes),
            filter_fields: :options,
            filters: [],
            sortings: []
          }
        end

        def index_collection_view_includes(member_includes = {})
          return {member_sequence: {}} unless include_collection_items?

          {member_sequence: {members: member_includes}}
        end

        def index_includes
          case requested_resource
          when LinkedRails::Sequence
            index_includes_sequence(preview_includes)
          when LinkedRails::Collection::View
            index_collection_view_includes(preview_includes)
          when LinkedRails::Collection
            index_collection_includes(preview_includes)
          end
        end

        def index_includes_sequence(member_includes = {})
          [members: member_includes]
        end

        def index_iri
          RDF::URI(request.original_url)
        end

        def index_meta
          if requested_resource.is_a?(LinkedRails.collection_class) ||
              requested_resource.is_a?(LinkedRails::Sequence) ||
              index_association.nil?
            return []
          end

          RDF::List.new(
            graph: RDF::Graph.new,
            subject: index_iri,
            values: index_association.map(&:iri)
          ).triples
        end

        def index_success_options_rdf
          {
            collection: requested_resource,
            include: index_includes,
            meta: index_meta
          }
        end
      end
    end
  end
end
