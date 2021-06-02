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
          @params_parser ||= LinkedRails::ParamsParser.new(params)
        end

        def parsed_filter_params
          filters = params_parser.filter_params

          ActionController::Parameters.new(controller_class.try(:attributes_from_filters, filters) || {})
        end

        def permit_filter_params
          @permit_filter_params ||= parsed_filter_params.permit(*permit_param_keys)
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
          permit_filter_params.merge(permit_params.to_h)
        end

        def resource_params
          return ActionController::Parameters.new if !params.key?(permit_param_key) && allow_empty_params?

          params.require(permit_param_key)
        end
      end
    end
  end
end