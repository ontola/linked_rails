# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/active_record'

module LinkedRails
  class InstallGenerator < ::Rails::Generators::Base
    include ::Rails::Generators::Migration
    source_root File.expand_path('templates', __dir__)
    desc 'Installs LinkedRails.'

    def install # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      template 'vocab.rb', 'lib/vocab.rb'
      template 'initializer.rb', 'config/initializers/linked_rails.rb'
      template 'application_form.rb', 'app/forms/application_form.rb'
      template 'application_menu_list.rb', 'app/menus/application_menu_list.rb'
      template 'application_policy.rb', 'app/policies/application_policy.rb'
      template 'application_serializer.rb', 'app/serializers/application_serializer.rb'
      template 'app_menu_list.rb', 'app/menus/app_menu_list.rb'
      template 'rdf_responder.rb', 'app/responders/rdf_responder.rb'
      template 'rdf_serializers_initializer.rb', 'config/initializers/rdf_serializers.rb'
      template 'locales.yml', 'config/locales/linked_rails.en.yml'
      template 'vocab.yml', 'config/locales/vocab.en.yml'
      route 'find_tenant_route'
      route 'use_linked_rails'
      application 'config.middleware.use LinkedRails::Middleware::LinkedDataParams'
      application 'config.jwt_encryption_method = :hs512'
      gsub_file('config/environments/development.rb', 'config.eager_load = false', 'config.eager_load = true')
      gsub_file('config/environments/development.rb', 'config.cache_classes = false', 'config.cache_classes = true')
      inject_includes

      readme 'README'
    end

    private

    def inject_includes
      inject_controller_include
      inject_model_include
    end

    def inject_controller_include
      sentinel = /class ApplicationController < ActionController::API\n/m
      in_root do
        inject_into_file(
          'app/controllers/application_controller.rb',
          optimize_indentation('include LinkedRails::Controller', 2),
          after: sentinel
        )
      end
    end

    def inject_model_include
      sentinel = /class ApplicationRecord < ActiveRecord::Base\n/m
      in_root do
        inject_into_file(
          'app/models/application_record.rb',
          optimize_indentation("include LinkedRails::Model\n", 2),
          after: sentinel
        )
      end
    end
  end
end
