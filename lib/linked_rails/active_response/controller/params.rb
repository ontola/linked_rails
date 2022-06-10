# frozen_string_literal: true

module LinkedRails
  module ActiveResponse
    module Controller
      module Params
        private

        def allow_empty_params?
          false
        end

        def params_parser
          @params_parser ||= LinkedRails::ParamsParser.new(params: params, user_context: user_context)
        end

        def permit_filter_params
          @permit_filter_params ||=
            policy(requested_resource || new_resource)
              .permitted_attributes_from_filters(params_parser.filter_params)
        end

        def permit_params
          @permit_params ||= resource_params.permit(*permit_param_keys)
        end

        def permit_param_key
          controller_name.singularize
        end

        def permit_param_keys
          @permit_param_keys ||= policy(current_resource_for_params).try(:permitted_attributes)
        end

        def permit_params_with_filters
          permitted = permit_filter_params.merge(permit_params.to_h)
          permitted[:singular_resource] = true if params[:singular_route].to_s == 'true'
          permitted
        end

        def resource_params
          empty_params = !params.key?(permit_param_key) || params[permit_param_key] == {}

          return ActionController::Parameters.new if empty_params && allow_empty_params?

          params.require(permit_param_key)
        end
      end
    end
  end
end
