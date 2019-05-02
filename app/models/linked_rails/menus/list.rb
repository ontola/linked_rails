# frozen_string_literal: true

module LinkedRails
  module Menus
    class List
      include ActiveModel::Model
      include LinkedRails::Model

      attr_accessor :resource, :user_context
      class_attribute :_defined_menus, instance_reader: false, instance_writer: false

      def available_menus
        return [] if defined_menus.blank?

        @available_menus ||= defined_menus.select(&method(:menu_available?)).compact
      end

      def defined_menus
        self.class.defined_menus
      end

      def menus
        @menus ||= available_menus.map(&method(:menu_item))
      end

      def menu(tag)
        menu_item(tag, available_menus[tag].dup) if available_menus.key?(tag)
      end

      private

      def menu_available?(_tag, options)
        options[:condition].nil? || call_option(options[:condition], resource)
      end

      def menu_item(tag, options) # rubocop:disable Metrics/AbcSize
        if options[:policy].present?
          return unless resource_policy(options[:policy_resource]).send(options[:policy], *options[:policy_arguments])
        end
        options[:label_params] ||= {}
        options[:label_params][:default] ||= ["menus.default.#{tag}".to_sym, tag.to_s.capitalize]
        options[:label] ||= I18n.t("menus.#{resource&.class&.name&.tableize}.#{tag}", options[:label_params])
        options.except!(:policy_resource, :policy, :policy_arguments, :label_params)
        LinkedRails.menus_item_class.new(resource: resource, tag: tag, parent: self, **options)
      end

      def resource_policy(policy_resource)
        policy_resource ||= resource
        policy_resource = instance_exec(&policy_resource) if policy_resource.respond_to?(:call)
        raise 'policy_resource is missing' if policy_resource.blank?

        @resource_policy ||= {}
        @resource_policy[policy_resource.identifier] ||= Pundit.policy(user_context, policy_resource)
      end

      def route_key
        [resource.iri_path[1..-1].presence, :menus].compact.join('/')
      end

      class << self
        def all
          []
        end

        def defined_menus
          initialize_menus
          _defined_menus || {}
        end

        def has_menu(tag, opts = {}) # rubocop:disable Naming/PredicateName
          defined_menus[tag] = opts
        end

        private

        def initialize_menus
          return if _defined_menus && method(:_defined_menus).owner == singleton_class

          self._defined_menus = superclass.try(:_defined_menus)&.dup || {}
        end
      end
    end
  end
end
