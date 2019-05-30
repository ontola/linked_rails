# frozen_string_literal: true

require_relative 'item'

module LinkedRails
  module Actions
    class List
      include ActiveModel::Model
      include LinkedRails::Model
      extend LinkedRails::Enhanceable

      attr_accessor :resource, :user_context
      class_attribute :_defined_actions, instance_reader: false, instance_writer: false

      def actions
        @actions ||= available_actions.map { |tag, opts| action_item(tag, opts.dup) }
      end

      def action(tag)
        actions.find { |a| a.tag == tag }
      end

      def available_actions
        return {} if defined_actions.blank?

        @available_actions ||= defined_actions.select(&method(:action_available?)).compact
      end

      def defined_actions
        self.class.defined_actions
      end

      private

      def action_available?(_tag, options)
        call_option(options[:collection], resource) == resource.is_a?(LinkedRails.collection_class) &&
          (options[:condition].nil? || call_option(options[:condition], resource))
      end

      def action_item(tag, options)
        options[:tag] ||= options[:action_tag] || tag
        options[:list] ||= self
        LinkedRails.actions_item_class.new(options.except(:condition, :action_tag))
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
          @actionable_class ||=
            name.gsub('ActionList', '').safe_constantize ||
            name.demodulize.gsub('ActionList', '').safe_constantize
        end

        def defined_actions
          initialize_actions
          _defined_actions || {}
        end

        private

        def initialize_actions
          return if _defined_actions && method(:_defined_actions).owner == singleton_class

          self._defined_actions = superclass.try(:_defined_actions)&.dup || {}
        end

        def has_action(action, opts = {}) # rubocop:disable Naming/PredicateName
          opts[:collection] ||= false
          defined_actions[action] = opts
        end
      end

      enhanceable :actionable_class, :Action
    end
  end
end
