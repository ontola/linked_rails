# frozen_string_literal: true

require 'linked_rails/constraints/whitelist'

module LinkedRails
  module Routes
    def use_linked_rails(opts = {}) # rubocop:disable Metrics/AbcSize
      constraints(LinkedRails::Constraints::Whitelist) do
        post 'spi/bulk', to: "#{opts.fetch(:bulk, 'linked_rails/bulk')}#show"
      end
      get '/c_a', to: "#{opts.fetch(:current_user)}#show"
      get '/ns/core', to: "#{opts.fetch(:vocabularies, 'linked_rails/vocabularies')}#show"
      get '/manifest', to: "#{opts.fetch(:manifests, 'linked_rails/manifests')}#show"
      get '/enums/:klass/:attribute', to: "#{opts.fetch(:enum_values, 'linked_rails/enum_values')}#index"
      get '/enums/*module/:klass/:attribute', to: "#{opts.fetch(:enum_values, 'linked_rails/enum_values')}#index"
      get '/forms/:id', to: "#{opts.fetch(:forms, 'linked_rails/forms')}#show"
      get '/forms/*module/:id', to: "#{opts.fetch(:forms, 'linked_rails/forms')}#show"
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
