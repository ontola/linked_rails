# frozen_string_literal: true

require 'linked_rails/constraints/whitelist'

module LinkedRails
  module Routes
    def use_linked_rails(opts = {}) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      constraints(LinkedRails::Constraints::Whitelist) do
        post 'spi/bulk', to: "#{opts.fetch(:bulk, 'linked_rails/bulk')}#show"
      end
      get '/c_a', to: "#{opts.fetch(:current_user, 'linked_rails/current_user')}#show"
      get '/ns/core', to: "#{opts.fetch(:ontologies, 'linked_rails/ontologies')}#show"
      get '/manifest', to: "#{opts.fetch(:manifests, 'linked_rails/manifests')}#show"
      get '/enums/:klass/:attribute', to: "#{opts.fetch(:enum_values, 'linked_rails/enum_values')}#index"
      get '/enums/*module/:klass/:attribute', to: "#{opts.fetch(:enum_values, 'linked_rails/enum_values')}#index"
      get '/forms/:id', to: "#{opts.fetch(:forms, 'linked_rails/forms')}#show"
      get '/forms/*module/:id', to: "#{opts.fetch(:forms, 'linked_rails/forms')}#show"

      get '(*parent_iri)/menus', to: "#{opts.fetch(:menus, 'linked_rails/menus')}/lists#index"
      get '(*parent_iri)/menus/:id', to: "#{opts.fetch(:menus, 'linked_rails/menus')}/lists#show"
      get '(*parent_iri)/menu_items', to: "#{opts.fetch(:menus, 'linked_rails/menus')}/items#index"

      get '(*parent_iri)/actions', to: "#{opts.fetch(:actions, 'linked_rails/actions')}/items#index"
      get '(*parent_iri)/actions/:id', to: "#{opts.fetch(:actions, 'linked_rails/actions')}/items#show"
    end

    def linked_resource(klass, controller: nil, collection: true, nested: false, resource: true, &block) # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists
      options = route_options(klass, controller, nested, klass.route_key)

      if collection
        get(options[:parentable_path], to: "#{options[:controller]}#index")
        route_block(
          klass,
          :collection,
          controller: options[:controller],
          prefix: options[:parentable_path]
        ).call
      end

      return unless resource

      resources(
        options[:route_name],
        active_controller_opts(options),
        &route_block(klass, :resource, &block)
      )
    end

    def singular_linked_resource(klass, controller: nil, nested: true, &block)
      options = route_options(klass, controller, nested, klass.singular_route_key)

      resource(
        options[:route_name],
        active_controller_opts(options).merge(singular_route: true),
        &route_block(klass, :singular, &block)
      )
    end

    def find_tenant_route
      get '_public/spi/find_tenant', to: 'linked_rails/manifests#tenant'
    end

    private

    def action_routes(controller, prefix, key, value)
      path = value.fetch(:action_path, key)
      action = value.fetch(:action_name)
      get([prefix, path].compact.join('/'), action: action, action_key: key, controller: controller)
      return if value[:target_path].nil?

      method = value.fetch(:http_method).downcase
      send(method, [prefix, value.fetch(:target_path)].compact.join('/'), action: key, controller: controller)
    end

    def active_controller_opts(route_options)
      {
        controller: route_options[:controller],
        only: %i[show],
        path: route_options[:nested] ? route_options[:parentable_path] : route_options[:path]
      }
    end

    def route_block(klass, action_type, controller: nil, prefix: nil)
      lambda do
        klass.action_list.defined_actions[action_type].each do |key, value|
          action_routes(controller, prefix, key, value)
        end
        yield if block_given?
      end
    end

    def route_options(klass, controller, nested, path)
      touch_controller(klass)

      {
        controller: controller || klass.name.tableize,
        nested: nested,
        only: %i[show],
        parentable_path: "(*parent_iri)/#{path}",
        path: path,
        route_name: klass.name.demodulize.tableize
      }.with_indifferent_access
    end

    # Make sure all actions are initialized before generating the routes
    def touch_controller(klass)
      klass.controller_class
    end
  end
end

ActionDispatch::Routing::Mapper.include LinkedRails::Routes

module LinkedRails
  module RoutingHelper
    def initialize(entities, api_only, shallow, options = {})
      options[:path] ||= entities.to_s.classify.safe_constantize.try(:route_key)
      super
    end
  end
end

ActionDispatch::Routing::Mapper::Resources::Resource.prepend(LinkedRails::RoutingHelper)
