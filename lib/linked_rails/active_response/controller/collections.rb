# frozen_string_literal: true

module LinkedRails
  module ActiveResponse
    module Controller
      module Collections
        private

        def action_form_includes(action = nil)
          LinkedRails::Enhancements::Actionable::FORM_INCLUDES + [resource: form_resource_includes(action)]
        end

        def collection_from_parent
          return if collection_from_parent_name.blank?

          parent_resource.send(
            collection_from_parent_name,
            collection_options
          )
        end

        def collection_from_parent_name
          return unless respond_to?(:parent_resource, true)
          return unless parent_resource.respond_to?("#{controller_name.singularize}_collection", true)

          "#{controller_name.singularize}_collection"
        end

        def collection_includes(member_includes = {})
          {
            default_view: collection_view_includes(member_includes),
            filters: [],
            sortings: [],
            operation: action_form_includes
          }
        end

        def collection_include_map
          JSONAPI::IncludeDirective::Parser.parse_include_args([:root] + [controller_class.includes_for_serializer])
        end

        def collection_view_includes(member_includes = {})
          {member_sequence: {members: member_includes}}
        end

        def collection_view_params
          params.permit(:before, :page)
        end

        def collection_options
          {
            display: params[:display],
            filter: parse_filter(params[:filter], controller_class.try(:filter_options)),
            include_map: collection_include_map,
            user_context: user_context
          }.merge(collection_type_params)
        end

        def collection_type_params
          params.permit(:page_size, :type)
        end

        def form_resource_includes(action)
          includes = controller_class.try(:show_includes)&.presence || []
          return includes if action.blank?

          includes = [includes] if includes.is_a?(Hash)
          includes << %i[filters sortings] if action.resource.is_a?(LinkedRails.collection_class)
          includes << action.form&.referred_resources
          includes
        end

        def index_collection
          @index_collection ||= collection_from_parent || root_collection
        end

        def index_collection_or_view
          collection_view_params.present? ? index_collection&.view_with_opts(collection_view_params) : index_collection
        end

        def index_includes_collection
          if collection_view_params.present?
            collection_view_includes(preview_includes)
          else
            collection_includes(preview_includes)
          end
        end

        def index_meta
          if index_collection.is_a?(LinkedRails.collection_class) || index_collection.is_a?(LinkedRails::Sequence)
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

        def parse_filter(array, whitelist)
          return {} if array.blank? || whitelist.blank?

          Hash[array&.map { |f| f.split('=') }].slice(*whitelist.keys)
        end

        def preview_includes
          controller_class.try(:preview_includes)
        end

        def root_collection
          LinkedRails.collection_class.new(collection_options.merge(association_class: controller_class))
        end

        def show_includes
          controller_class.try(:show_includes)
        end
      end
    end
  end
end
