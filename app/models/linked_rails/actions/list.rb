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
        @actions ||= defined_actions.map { |tag, opts| action_item(tag, opts.dup) }
      end

      def action(tag)
        actions.find { |a| a.tag == tag }
      end

      def defined_actions
        if resource.is_a?(LinkedRails.collection_class)
          self.class.collection_actions
        else
          self.class.model_actions
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
          @collection_actions ||= defined_actions.select { |_tag, opts| opts[:collection] }
        end

        def defined_actions
          initialize_actions
          _defined_actions || {}
        end

        def model_actions
          @model_actions ||= defined_actions.reject { |_tag, opts| opts[:collection] }
        end

        private

        def initialize_actions
          return if _defined_actions && method(:_defined_actions).owner == singleton_class

          self._defined_actions = superclass.try(:_defined_actions)&.dup || {}
        end

        def has_action(action, opts = {}) # rubocop:disable Naming/PredicateName
          opts[:collection] ||= false
          opts[:http_method] ||= 'POST'
          defined_actions[action] = opts
        end
      end

      enhanceable :actionable_class, :Action
    end
  end
end
