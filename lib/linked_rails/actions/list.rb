# frozen_string_literal: true

module LinkedRails
  module Actions
    class List
      include ActiveModel::Model

      attr_accessor :resource
      class_attribute :defined_actions

      def actions
        available_actions.map { |tag, opts| action_item(tag, opts) }
      end

      def action(tag)
        action_item(tag, available_actions[tag]) if available_actions.key?(tag)
      end

      def available_actions
        self.class.initialize_actions

        return {} if defined_actions.blank?

        @available_actions ||= defined_actions.select(&method(:action_available?)).compact
      end

      private

      def action_available?(_tag, options)
        call_option(options[:collection], resource) == resource.is_a?(LinkedRails.collection_class) &&
          (options[:condition].nil? || call_option(options[:condition], resource))
      end

      def action_item(tag, options)
        options[:tag] ||= tag
        options[:list] ||= self
        self.class.action_item_class.new(options.except(:condition))
      end

      def association
        @association ||= result_class.to_s.tableize
      end

      def call_option(option, _resource)
        option.respond_to?(:call) ? instance_exec(&option) : option
      end

      def result_class
        @result_class ||= create_on_collection? ? resource.association_class : self.class.actionable_class
      end

      class << self
        def actionable_class
          @actionable_class ||= name.gsub('ActionList', '').safe_constantize
        end

        def action_item_class
          Item
        end

        def initialize_actions
          return if defined_actions && method(:defined_actions).owner == singleton_class

          self.defined_actions = superclass.try(:defined_actions)&.dup || {}
          actionable_class.try(:enhancement_modules, :Action)&.each { |mod| include mod }
        end

        private

        def has_action(action, opts = {}) # rubocop:disable Naming/PredicateName
          initialize_actions

          opts[:collection] ||= false
          defined_actions[action] = opts
        end
      end
    end
  end
end
