# frozen_string_literal: true

require 'linked_rails/constraints/whitelist'

module LinkedRails
  module Routes
    def use_linked_rails(opts = {}) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      constraints(LinkedRails::Constraints::Whitelist) do
        post 'spi/bulk', to: "#{opts.fetch(:bulk, 'linked_rails/bulk')}#show"
      end
      get '/c_a', to: "#{opts.fetch(:current_user)}#show"
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
      get '(*parent_iri)/new', to: "#{opts.fetch(:actions, 'linked_rails/actions')}/items#show", id: :create
      get '(*parent_iri)/edit', to: "#{opts.fetch(:actions, 'linked_rails/actions')}/items#show", id: :update
      get '(*parent_iri)/delete', to: "#{opts.fetch(:actions, 'linked_rails/actions')}/items#show", id: :destroy
      get '(*parent_iri)/trash', to: "#{opts.fetch(:actions, 'linked_rails/actions')}/items#show", id: :trash
      get '(*parent_iri)/untrash', to: "#{opts.fetch(:actions, 'linked_rails/actions')}/items#show", id: :untrash
    end

    def linked_resource(klass, controller: nil, nested: false, &block)
      options = route_options(klass, controller, nested, klass.route_key)

      resources(
        options[:route_name],
        active_controller_opts(options),
        &route_block(klass, &block)
      )

      post(options[:parentable_path], to: "#{options[:controller]}#create") if options[:creatable]
      get(options[:parentable_path], to: "#{options[:controller]}#index")
    end

    def singular_linked_resource(klass, controller: nil, nested: true, &block)
      options = route_options(klass, controller, nested, klass.singular_route_key)

      resource(
        options[:route_name],
        active_controller_opts(options).merge(singular_route: true),
        &route_block(klass, &block)
      )

      post(options[:parentable_path], to: "#{options[:controller]}#create", singular_route: true) if options[:creatable]
    end

    private

    def active_controller_opts(route_options)
      {
        controller: route_options[:controller],
        only: %i[show],
        path: route_options[:nested] ? route_options[:parentable_path] : route_options[:path]
      }
    end

    def creatable(klass)
      klass.enhanced_with?(LinkedRails::Enhancements::Creatable, :Routing)
    end

    def route_block(klass)
      lambda do
        include_route_concerns(klass: klass)

        yield if block_given?
      end
    end

    def route_options(klass, controller, nested, path)
      {
        controller: controller || klass.name.tableize,
        creatable: creatable(klass),
        nested: nested,
        only: %i[show],
        parentable_path: "(*parent_iri)/#{path}",
        path: path,
        route_name: klass.name.demodulize.tableize
      }.with_indifferent_access
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
