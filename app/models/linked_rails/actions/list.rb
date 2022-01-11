# frozen_string_literal: true

require_relative 'item'

module LinkedRails
  module Actions
    class List
      include ActiveModel::Model
      include LinkedRails::Model

      attr_accessor :resource, :user_context
      class_attribute :_defined_actions, instance_reader: false, instance_writer: false

      def actions
        @actions ||= defined_actions.map { |tag, opts| action_item(tag, opts.dup) }.select(&:available?)
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
        options[:tag] ||= tag
        options[:list] ||= self
        LinkedRails.actions_item_class.new(options.except(:action_name))
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

        def initial_defined_actions(clone_from = {})
          {
            collection: clone_from[:collection].dup&.select { |_, value| value[:inherit] != false } || {},
            resource: clone_from[:resource].dup&.select { |_, value| value[:inherit] != false } || {},
            singular: clone_from[:singular].dup&.select { |_, value| value[:inherit] != false } || {}
          }
        end

        def initialize_actions
          return if _defined_actions && method(:_defined_actions).owner == singleton_class

          self._defined_actions = initial_defined_actions(superclass.try(:_defined_actions) || {})
        end
      end
    end
  end
end
