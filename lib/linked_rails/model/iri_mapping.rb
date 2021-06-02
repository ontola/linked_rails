# frozen_string_literal: true

module LinkedRails
  module Model
    module IriMapping
      extend ActiveSupport::Concern

      module ClassMethods
        def parent_from_params(params, user_context)
          LinkedRails.iri_mapper.parent_from_params(params, user_context)
        end

        def requested_index_resource(params, user_context)
          if params.key?(:parent_iri)
            collection_from_parent(index_collection_params(params, user_context))
          else
            root_collection(index_collection_params(params, user_context))
          end
        end

        def requested_index_resource!(params, user_context)
          requested_index_resource(params, user_context) || raise(ActiveRecord::RecordNotFound)
        end

        def requested_resource(opts, user_context)
          if collection_action?(opts)
            requested_index_resource(opts[:params], user_context)
          elsif singular_action?(opts)
            resource = requested_singular_resource(opts[:params], user_context)
            resource&.singular_resource = true
            resource
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

        private

        def collection_action?(opts)
          %w[index create].include?(opts[:action]) && !opts[:params][:singular_route]
        end

        def index_collection_params(params, user_context)
          params_hash = params.is_a?(ActionController::Parameters) ? params.to_unsafe_h : params

          {
            user_context: user_context
          }.merge(params_hash).with_indifferent_access
        end

        def singular_action?(opts)
          opts[:params][:singular_route]
        end
      end
    end
  end
end
