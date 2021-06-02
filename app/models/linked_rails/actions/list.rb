# frozen_string_literal: true

require_relative 'item'

module LinkedRails
  module Actions
    class List
      include ActiveModel::Model
      include LinkedRails::Model
      include DefaultActions
      extend LinkedRails::Enhanceable

      attr_accessor :resource, :user_context
      class_attribute :_defined_actions, instance_reader: false, instance_writer: false

      def actions
        @actions ||= defined_actions.map { |tag, opts| action_item(tag, opts.dup) }
      end

      def action(tag)
        action_item(tag, defined_actions[tag].dup) if defined_actions.key?(tag)
      end

      def defined_actions
        if resource.is_a?(LinkedRails.collection_class)
          self.class.collection_actions
        elsif resource.try(:singular_resource?)
          self.class.singular_actions
        else
          self.class.resource_actions
        end
      end

      private

      def action_item(tag, options)
        options[:tag] ||= options[:action_tag] || tag
        options[:list] ||= self
        LinkedRails.actions_item_class.new(options.except(:action_tag))
      end

      def association
        @association ||= result_class.to_s.demodulize.tableize
      end

      def call_option(option, _resource)
        option.respond_to?(:call) ? instance_exec(&option) : option
      end

      def result_class
        @result_class ||= self.class.actionable_class
      end

      class << self
        def actionable_class
          @actionable_class ||=
            name.gsub('ActionList', '').safe_constantize ||
            name.demodulize.gsub('ActionList', '').safe_constantize
        end

        def collection_actions
          defined_actions[:collection]
        end

        def defined_actions
          initialize_actions
          _defined_actions || initial_defined_actions
        end

        def resource_actions
          defined_actions[:resource]
        end

        def singular_actions
          defined_actions[:singular]
        end

        private

        def has_collection_action(action, opts = {}) # rubocop:disable Naming/PredicateName
          opts[:http_method] ||= 'POST'
          defined_actions[:collection][action] = opts
        end

        def has_resource_action(action, opts = {}) # rubocop:disable Naming/PredicateName
          opts[:http_method] ||= 'POST'
          defined_actions[:resource][action] = opts
        end

        def has_singular_action(action, opts = {}) # rubocop:disable Naming/PredicateName
          opts[:http_method] ||= 'POST'
          defined_actions[:singular][action] = opts
        end

        def initial_defined_actions(clone_from = {})
          {
            collection: clone_from[:collection].dup || {},
            resource: clone_from[:resource].dup || {},
            singular: clone_from[:singular].dup || {}
          }
        end

        def initialize_actions
          return if _defined_actions && method(:_defined_actions).owner == singleton_class

          self._defined_actions = initial_defined_actions(superclass.try(:_defined_actions) || {})
        end
      end

      enhanceable :actionable_class, :Action
    end
  end
end
