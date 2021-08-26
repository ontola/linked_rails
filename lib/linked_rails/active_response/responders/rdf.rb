# frozen_string_literal: true

require 'active_response/responders/html'

module LinkedRails
  module ActiveResponse
    module Responders
      class RDF < ::ActiveResponse::Responders::HTML # rubocop:disable Metrics/ClassLength
        respond_to(*LinkedRails::Renderers.rdf_content_types)

        include LinkedRails::Helpers::OntolaActionsHelper

        def collection(opts)
          opts[:resource] = opts.delete(:collection)
          controller.respond_with_resource opts
        end

        def destroyed(opts)
          response_headers(opts)
          if opts[:meta].present?
            controller.render(format => [], location: opts[:location], meta: opts[:meta])
          else
            controller.head 200, location: opts[:location], content_type: content_type
          end
        end

        def form(**opts)
          response_headers(opts)
          controller.respond_with_resource(
            resource: opts[:action],
            include: opts[:include],
            meta: opts[:meta]
          )
        end

        def invalid_resource(**opts)
          response_headers(opts)
          controller.respond_with_resource(
            resource: nil,
            meta: error_meta(opts[:resource]),
            status: :unprocessable_entity
          )
        end

        def new_resource(**opts)
          opts[:status] = :created
          controller.respond_with_resource(opts)
        end

        def redirect(**opts) # rubocop:disable Metrics/AbcSize
          return super if controller.request.head?

          response_headers(opts)
          add_exec_action_header(
            controller.response.headers,
            ontola_redirect_action(opts[:location], reload: opts[:reload])
          )
          controller.head 200, content_type: content_type, location: opts[:location]
        end

        def resource(**opts) # rubocop:disable Metrics/AbcSize
          response_headers(opts)

          if (opts[:resource].blank? && opts[:meta].blank?) || head_request?
            controller.head(opts[:status] || 200, location: opts[:location], content_type: content_type)
          else
            opts[format] = opts.delete(:resource) || []
            controller.render opts
          end
        end

        def updated_resource(**opts)
          response_headers(opts)
          if opts[:meta].present?
            controller.render(format => [], meta: opts[:meta], location: opts[:location])
          else
            controller.head 200, location: opts[:location], content_type: content_type
          end
        end

        private

        def error_mapping(form_iri, error_object)
          [
            ::RDF::URI(form_iri),
            Vocab.ll[:errorResponse],
            error_object,
            Vocab.ontola[:replace]
          ]
        end

        def error_statements(iri, resource)
          index = 0
          resource.errors.messages.map do |key, values|
            predicate = resource.class.predicate_for_key(key.to_s.split('.').first)
            if predicate
              error_statements_for(iri, predicate, values)
            else
              index += 1
              unassigned_error_statements(resource, iri, index - 1, key, values)
            end
          end.compact.flatten(1)
        end

        def error_statements_for(iri, predicate, values)
          values.map { |value| [iri, predicate, value.sub(/\S/, &:upcase)] }
        end

        def error_meta(resource)
          form_iri = controller.request.headers['Request-Referrer']
          return [] unless form_iri && resource.respond_to?(:errors)

          error_object = ::RDF::Node.new
          [
            error_mapping(form_iri, error_object),
            error_type(error_object),
            error_status(error_object)
          ] + error_statements(error_object, resource)
        end

        def error_type(error_object)
          [
            error_object,
            Vocab.rdfv.type,
            Vocab.ll[:ErrorResponse],
            Vocab.ontola[:replace]
          ]
        end

        def error_status(error_object)
          [
            error_object,
            ::RDF::URI('http://www.w3.org/2011/http#statusCode'),
            200,
            Vocab.ll[:meta]
          ]
        end

        def head_request?
          controller.request.method == 'HEAD'
        end

        def response_headers(opts)
          headers = controller.response.headers
          add_exec_action_header(headers, ontola_snackbar_action(opts[:notice])) if opts[:notice].present?
        end

        def unassigned_error_statements(resource, iri, index, key, values)
          error_statements_for(
            iri,
            ::RDF["_#{index}"],
            values.map { |value| resource.errors.full_message(key, value) }
          )
        end
      end
    end
  end
end
