# frozen_string_literal: true

module LinkedRails
  module ActiveResponse
    module Controller
      module Collections
        private

        def collection_includes(member_includes = {})
          {
            default_view: collection_view_includes(member_includes),
            filter_fields: :options,
            filters: [],
            sortings: []
          }
        end

        def collection_include_map
          JSONAPI::IncludeDirective::Parser.parse_include_args(
            [:root] + [controller_class.try(:includes_for_serializer)]
          )
        end

        def collection_view_includes(member_includes = {})
          {member_sequence: {members: member_includes}}
        end

        def collection_view_params(opts = params)
          method = opts.is_a?(Hash) ? :slice : :permit
          options = opts.send(method, [:page, before: []])
          before = parse_before(options[:before])
          options[:before] = before if before
          options
        end

        def collection_options
          {
            include_map: collection_include_map,
            user_context: user_context
          }.merge(collection_params)
        end

        def collection_or_view(collection)
          collection_view_params.present? ? collection&.view_with_opts(collection_view_params) : collection
        end

        def collection_params(opts = params, _klass = controller_class) # rubocop:disable Metrics/AbcSize
          method = opts.is_a?(Hash) ? :slice : :permit
          params = opts.send(method, :display, :page_size, :title, :type).to_h.with_indifferent_access

          filter = parse_filter(opts.is_a?(Hash) ? opts[:filter] : opts.permit(filter: [])[:filter])
          params[:filter] = filter if filter

          sort = parse_sort(opts.is_a?(Hash) ? opts[:sort] : opts.permit(sort: [])[:sort])
          params[:sort] = sort if sort

          params
        end

        def index_association; end

        def index_collection; end

        def index_collection_or_view
          @index_collection_or_view ||= collection_or_view(index_collection)
        end

        def index_includes_collection
          if collection_view_params.present?
            collection_view_includes(preview_includes)
          else
            collection_includes(preview_includes)
          end
        end

        def index_includes_sequence
          [members: preview_includes]
        end

        def index_meta
          if index_collection.is_a?(LinkedRails.collection_class) ||
            index_collection.is_a?(LinkedRails::Sequence) ||
            index_collection.nil?
            return []
          end

          RDF::List.new(
            graph: RDF::Graph.new,
            subject: index_iri,
            values: index_collection.map(&:iri)
          ).triples
        end

        def index_iri
          RDF::URI(request.original_url)
        end

        def index_sequence
          return if index_association.nil?

          @index_sequence ||=
            LinkedRails::Sequence.new(
              index_association,
              id: index_iri
            )
        end

        def parse_before(array)
          return if array.blank?

          array&.map do |f|
            key, value = f.split('=')
            {key: RDF::URI(CGI.unescape(key)), value: value}
          end
        end

        def parse_filter(array)
          return {} if array.blank?

          array.each_with_object({}) do |f, hash|
            values = f.split('=')
            key = RDF::URI(CGI.unescape(values.first))
            hash[key] ||= []
            hash[key] << CGI.unescape(values.second)
          end
        end

        def parse_sort(array)
          return if array.blank?

          array&.map do |f|
            key, value = f.split('=')
            {key: RDF::URI(CGI.unescape(key)), direction: value}
          end
        end
      end
    end
  end
end
