# frozen_string_literal: true

require_relative 'default_actions/create'
require_relative 'default_actions/destroy'
require_relative 'default_actions/update'

module LinkedRails
  module Controller
    module Actionable
      ACTION_METHOD_MAPPING = {
        execute: :execute,
        on_failure: :failure,
        on_success: :success
      }.freeze

      extend ActiveSupport::Concern

      included do
        extend LinkedRails::Controller::DefaultActions::Create
        extend LinkedRails::Controller::DefaultActions::Destroy
        extend LinkedRails::Controller::DefaultActions::Update
      end

      class_methods do
        def has_collection_action(action, **opts)
          has_action(:collection, action, **opts)
        end

        def has_singular_action(action, **opts)
          has_action(:singular, action, **opts)
        end

        def has_resource_action(action, **opts)
          has_action(:resource, action, **opts)
        end

        private

        # @param [:resource, :singular, :collection] type To which action list the action is added
        # @param [symbol] action_key A key to identify the action
        # @param [Hash] opts The options for the action
        # @option opts [symbol] :action_name The name for the controller action for GETting this action.
        #   A route is automatically generated. Defaults to the action key
        # @option opts [proc<string>, string] :action_path The path to be appended to the resource iri.
        #   Defaults to "#{action_key}_action"
        # @option opts [proc<string>, string] :description The description of this action
        # @option opts [symbol] :execute The controller method to use when this action is executed.
        #   Defaults to "#{action}_execute"
        # @option opts [proc<boolean>, boolean] :favorite Whether or not this is a favorite action
        # @option opts [proc<LinkedRails::Form>, LinkedRails::Form] :form The form for this action
        # @option opts [proc<string>, string] :http_method The method to be used in the request.
        #   GET, HEAD, POST, PUT, DELETE, CONNECT, OPTIONS, TRACE, PATCH
        #   Defaults to POST
        # @option opts [proc<string>, string] :image A fontawesome icon, prepended with 'fa-'
        # @option opts [boolean] :inherit Whether descendant controllers should clone this action.
        #   Defaults to true
        # @option opts [boolean] :one_click Whether the action can be executed with one click.
        #   Defaults to false
        # @option opts [proc<string>, string] :label The label of the action
        # @option opts [LinkedRails::Model] :object The object on which the action will be executed
        #   Defaults to the resource
        # @option opts [symbol] :on_failure Callback when the execute method failed.
        #   Defaults to "#{action}_failure"
        # @option opts [symbol] :on_success Callback when the execute method succeeded.
        #   Defaults to "#{action}_success"
        # @option opts [symbol] :policy The method to be called on the policy of the policy_resource
        # @option opts [Array<symbol>] :policy_arguments The arguments passed to the policy method
        # @option opts [proc<LinkedRails::Model>, LinkedRails::Model] :policy_resource
        #   The resource on which a policy needs to be authorized.
        #   Defaults to the object
        # @option opts [proc<RDF::URI>, RDF::URI] :predicate The relation between the resource and the action
        # @option opts [proc<LinkedRails::Model>, LinkedRails::Model] :result
        # @option opts [proc<string>, string] :submit_label The label for the submit button of the action
        # @option opts [proc<string>, string] :target_url The url whereto the request will be made.
        #   Use target_path/target_query  when the url starts with the iri of the resource, so a route can be generated.
        # @option opts [string] :target_path The path appended to the iri of the resource to determine
        #   the url whereto the request will be made. A route is automatically generated.
        #   Defaults to the action key
        # @option opts [hash] :target_query The query appended to the iri of the resource to determine
        # @option opts [array<RDF::URI>, RDF::URI] :type The rdf type of the action.
        #   Defaults to schema.UpdateAction
        def has_action(type, action_key, opts)
          opts[:action_name] ||= "#{action_key}_action"
          opts[:http_method] ||= 'POST'
          opts[:target_path] ||= action_key if opts[:target_url].blank?

          active_response(action_key, opts[:action_name])
          define_action_show_method(action_key, opts)
          define_action_execute_methods(action_key, opts)
          controller_class.action_list.defined_actions[type][action_key] = opts
        end

        def define_action_execute_methods(action_key, opts)
          ACTION_METHOD_MAPPING.each do |key, value|
            define_action_execute_method(action_key, key, value, opts)
          end
        end

        def define_action_execute_method(action, key, suffix, opts)
          call_method = opts.delete(key)
          method_name = :"#{action}_#{suffix}"
          return if call_method.blank? || method_name == call_method

          define_method(method_name) do
            if call_method.is_a?(Symbol)
              send(call_method)
            else
              instance_exec(&call_method)
            end
          end
        end

        def define_action_show_method(_action, opts)
          define_method("#{opts[:action_name]}_success") do
            respond_with_resource(show_success_options)
          end
        end
      end
    end
  end
end
