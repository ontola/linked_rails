# frozen_string_literal: true

module LinkedRails
  module Model
    module IRIMapping
      extend ActiveSupport::Concern

      module ClassMethods
        def parent_from_params(params, user_context)
          LinkedRails.iri_mapper.parent_from_params(params, user_context)
        end

        def parent_from_params!(params, user_context)
          parent_from_params(params, user_context) || raise(ActiveRecord::RecordNotFound)
        end

        def requested_action(opts, user_context)
          action_key = opts[:params][:action_key]
          resource = LinkedRails.iri_mapper.resource_from_iri(
            iri_without_action(opts[:iri]),
            user_context
          )
          resource&.action(action_key, user_context)
        end

        def requested_index_resource(params, user_context)
          if params.key?(:parent_iri)
            collection_from_parent(index_collection_params(params, user_context))
          else
            root_collection(**index_collection_params(params, user_context))
          end
        end

        def requested_index_resource!(params, user_context)
          requested_index_resource(params, user_context) || raise(ActiveRecord::RecordNotFound)
        end

        def requested_resource(opts, user_context)
          if collection_action?(opts)
            requested_index_resource(opts[:params], user_context)
          elsif action_item_action?(opts)
            requested_action(opts, user_context)
          elsif singular_action?(opts)
            singular_resource(requested_singular_resource(opts[:params], user_context))
          else
            requested_single_resource(opts[:params], user_context)
          end
        end

        def requested_single_resource(params, _user_context)
          if self < ActiveRecord::Base
            find_by(primary_key => params[:id]) if params.key?(:id)
          else
            new(params)
          end
        end

        def requested_single_resource!(params, user_context)
          requested_single_resource(params, user_context) || raise(ActiveRecord::RecordNotFound)
        end

        def singular_resource(resource)
          resource&.singular_resource = true
          resource
        end

        private

        def action_item_action?(opts)
          opts[:params][:action_key].present?
        end

        def collection_action?(opts)
          opts[:action] == 'index' ||
            opts[:class].action_list.defined_actions[:collection].key?(opts[:action].to_sym)
        end

        def index_collection_params(params, user_context)
          params_hash = params.is_a?(ActionController::Parameters) ? params.to_unsafe_h : params

          {
            user_context: user_context
          }.merge(params_hash).symbolize_keys
        end

        def iri_without_action(url)
          iri = RDF::URI(url)
          iri.path = iri.path.split('/')[0...-1].join('/')
          iri.to_s
        end

        def singular_action?(opts)
          opts[:params][:singular_route]
        end
      end
    end
  end
end
