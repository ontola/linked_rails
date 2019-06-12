# frozen_string_literal: true

module LinkedRails
  module ActiveResponse
    module Controller
      module ResourceHelper
        def parent_resource
          @parent_resource ||= parent_from_params(params)
        end

        def parent_resource!
          parent_resource || raise(ActiveRecord::RecordNotFound)
        end

        # Extracts a parent resource from an IRI based on the rails routes
        # @param iri [String, RDF::URI] The iri to resolve.
        # @return [ApplicationRecord, nil] The parent resource corresponding to the uri if found
        def parent_from_iri(iri)
          route_opts = Rails.application.routes.recognize_path(iri)
          parent_from_params(route_opts)
        rescue ActionController::RoutingError
          nil
        end

        # Finds the parent resource based on the URL's :foo_id param
        # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
        # @return [ApplicationRecord, nil] The parent resource corresponding to the params if found
        def parent_from_params(opts = params)
          opts = opts.dup
          opts[:class] = parent_resource_class(opts)
          opts[:id] = opts.delete(parent_resource_param(opts))
          parent_resource_or_collection(opts)
        end

        # Extracts the resource id from a params hash
        # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
        # @return [String] The resource id
        # @example Resource class from resource_id
        #   params = {resource_id: 1}
        #   parent_id_from_params # => '1'
        def parent_id_from_params(opts = params)
          opts[parent_resource_param(opts)]
        end

        # Determines the parent resource's class from the request
        # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
        # @return [ApplicationRecord] The parent resource class object
        # @see #parent_resource_klass
        def parent_resource_class(opts = params)
          parent_resource_klass(opts)
        end

        # Finds a 'resource key' from a params Hash
        # @example Resource key from motion_id
        #   params = {resource_id: 1}
        #   parent_resource_key # => :resource_id
        def parent_resource_key(hash)
          hash
            .keys
            .reverse
            .find { |k| /_id/ =~ k }
        end

        # Constantizes a class string from the params hash
        # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
        # @return [ApplicationRecord] The parent resource class object
        # @note Whether the given parent is allowed for the requested resource is not validated here.
        def parent_resource_klass(opts = params)
          ApplicationRecord.descendants.detect { |m| m.to_s == parent_resource_type(opts)&.classify }
        end

        def parent_resource_or_collection(opts) # rubocop:disable Metrics/AbcSize
          resource = resource_from_opts(opts.merge(type: controller_name))
          return resource if opts[:collection].blank?

          collection_class = opts[:collection].classify.constantize
          collection_opts = collection_params(opts, collection_class)

          if resource.present?
            resource.send("#{opts[:collection].to_s.singularize}_collection", collection_opts)
          else
            collection_class.try(:root_collection, collection_opts)
          end
        end

        # Extracts the parent resource param from the url to get to its value
        # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
        # @return [Symbol] The resource param
        # @see #parent_resource_key
        def parent_resource_param(opts = params)
          parent_resource_key(opts)
        end

        # Extracts the resource type string from a params hash
        # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
        # @return [String] The resource type string
        # @example Resource type from resource_id
        #   params = {resource_id: 1}
        #   parent_resource_type # => 'resource'
        def parent_resource_type(opts = params)
          key = parent_resource_key(opts)
          key[0..-4] if key
        end

        def resource_by_id_from_opts(opts)
          opts[:class]&.find_by(id: opts[:id])
        end

        def resource_from_opts(opts)
          opts[:class] ||= ApplicationRecord.descendants.detect { |m| m.to_s == opts[:type].classify } if opts[:type]
          return if opts[:class].blank? || opts[:id].blank?

          resource_by_id_from_opts(opts)
        end
      end
    end
  end
end
