# frozen_string_literal: true

module LinkedRails
  module Menus
    class List
      include ActiveModel::Model
      include LinkedRails::Model

      attr_accessor :resource, :user_context
      class_attribute :_defined_menus, instance_reader: false, instance_writer: false

      def available_menus
        return {} if defined_menus.blank?

        @available_menus ||= defined_menus.select(&method(:menu_available?)).compact
      end

      def defined_menus
        self.class.defined_menus
      end

      def iri_opts
        return {} if resource.blank?

        resource.try(:singular_resource?) ? resource.singular_iri_opts : resource.iri_opts
      end

      def menus
        @menus ||= available_menus.map(&method(:menu_item))
      end

      def menu(tag)
        menu_item(tag, available_menus[tag].dup) if available_menus.key?(tag)
      end

      private

      def default_label(tag, options)
        I18n.t("menus.#{resource&.class&.name&.tableize}.#{tag}", **options[:label_params])
      end

      def menu_available?(_tag, options)
        options[:condition].nil? || call_option(options[:condition], resource)
      end

      def menu_item(tag, options) # rubocop:disable Metrics/AbcSize
        if options[:policy].present?
          return unless resource_policy(options[:policy_resource]).send(options[:policy], *options[:policy_arguments])
        end
        options[:label_params] ||= {}
        options[:label_params][:default] ||= ["menus.default.#{tag}".to_sym, tag.to_s.capitalize]
        options[:label] ||= default_label(tag, options)
        options[:action] = ontola_dialog_action(options[:href]) if options.delete(:dialog)
        options.except!(:policy_resource, :policy, :policy_arguments, :label_params)
        LinkedRails.menus_item_class.new(resource: resource, tag: tag, parent: self, **options)
      end

      def resource_policy(policy_resource)
        policy_resource ||= resource
        policy_resource = instance_exec(&policy_resource) if policy_resource.respond_to?(:call)
        raise 'policy_resource is missing' if policy_resource.blank?

        @resource_policy ||= {}
        @resource_policy[policy_resource] ||= Pundit.policy(user_context, policy_resource)
      end

      def iri_template
        base_template = resource.send(resource.try(:singular_resource?) ? :singular_iri_template : :iri_template)

        @iri_template ||= iri_template_expand_path(base_template, '/menus')
      end

      class << self
        def app_menu_list_class
          return @app_menu_list_class if instance_variables.include?(:@app_menu_list_class)

          @app_menu_list_class = 'AppMenuList'.safe_constantize
        end

        def app_menu_list(user_context)
          app_menu_list_class&.new(
            resource: nil,
            user_context: user_context
          )
        end

        def all
          []
        end

        def defined_menus
          initialize_menus
          _defined_menus || {}
        end

        def has_menu(tag, **opts)
          defined_menus[tag] = opts
        end

        def requested_index_resource(params, user_context)
          menu_list = menu_list_from_params(params, user_context)

          return if menu_list.blank?

          LinkedRails::Sequence.new(
            menu_list.menus,
            id: menu_list.iri,
            member_includes: Item.preview_includes,
            scope: false
          )
        end

        def requested_single_resource(params, user_context)
          return nil if params[:id].blank?

          menu_list = menu_list_from_params(params, user_context)

          menu_list&.menu(params[:id].to_sym)
        end

        private

        def initialize_menus
          return if _defined_menus && method(:_defined_menus).owner == singleton_class

          self._defined_menus = superclass.try(:_defined_menus)&.dup || {}
        end

        def menu_list_from_params(params, user_context)
          parent = parent_from_params(params, user_context)

          if parent.is_a?(LinkedRails.menus_item_class)
            parent
          elsif parent
            parent.menu_list(user_context)
          else
            app_menu_list(user_context)
          end
        end
      end
    end
  end
end
