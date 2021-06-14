# frozen_string_literal: true

module LinkedRails
  module ActiveResponse
    module Controller
      module Collections
        private

        def index_association; end

        def index_includes
          requested_resource.preview_includes
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
