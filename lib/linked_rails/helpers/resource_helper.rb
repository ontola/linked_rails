# frozen_string_literal: true

module LinkedRails
  module Helpers
    module ResourceHelper
      def current_resource
        return @current_resource if instance_variable_defined?(:@current_resource)

        @current_resource ||= resolve_current_resource
      end

      def new_resource
        @new_resource ||=
          if requested_resource.try(:singular_resource?)
            requested_resource
          elsif parent_resource
            new_resource_from_parent
          else
            build_new_resource
          end
      end

      def params_for_parent
        params.dup
      end

      def parent_from_params
        @parent_from_params ||= LinkedRails.iri_mapper.parent_from_params(params, user_context)
      end

      def parent_from_params!
        parent_from_params || raise(ActiveRecord::RecordNotFound)
      end

      def parent_resource
        @parent_resource ||= requested_resource_parent || parent_from_params
      end

      def parent_resource!
        parent_resource || raise(ActiveRecord::RecordNotFound)
      end

      def requested_resource_parent
        requested_resource.try(:parent)
      end

      private

      def build_new_resource
        controller_class.build_new(user_context: user_context)
      end

      def new_resource_from_parent
        parent_resource.build_child(
          controller_class,
          user_context: user_context
        )
      end

      def resolve_current_resource
        case action_name
        when 'create'
          new_resource
        else
          requested_resource
        end
      end
    end
  end
end
