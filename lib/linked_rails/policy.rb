# frozen_string_literal: true

require_relative 'active_response/controller'
require_relative 'controller/error_handling'
require_relative 'policy/attribute_conditions'

module LinkedRails
  module Policy
    extend ActiveSupport::Concern

    included do
      extend Enhanceable
      include AttributeConditions

      enhanceable :policy_class, :Policy
      class_attribute :_permitted_attributes

      attr_reader :action_status, :message, :user_context, :record

      def initialize(user_context, record)
        @user_context = user_context
        @record = record
      end
    end

    def create_child?(klass, **opts)
      child_policy(klass, **opts).create?
    end

    def index_children?(klass, **opts)
      child_policy(klass, **opts).show?
    end

    def permitted_attributes
      self.class.permitted_attributes
        .select { |opts| attribute_permitted?(opts[:conditions]) }
        .map { |opts| sanitized_attributes(opts[:attributes], opts[:options] || {}) }
        .flatten
    end

    def policy_class
      self.class.policy_class
    end

    def show?
      false
    end

    def update?
      false
    end

    def create?
      false
    end

    def destroy?
      false
    end

    private

    def attribute_permitted?(conditions)
      conditions.all? do |key, opts|
        raise "Unknown attribute condition #{key}" unless respond_to?("check_#{key}", true)

        send(:"check_#{key}", opts)
      end
    end

    def child_policy(klass, **opts)
      Pundit.policy(user_context, record.build_child(klass, **opts.merge(user_context: user_context)))
    end

    def forbid_with_message(message, status = nil)
      forbid_with_status(status) if status
      @message = message
      false
    end

    def forbid_with_status(status, message = nil)
      forbid_with_message(message) if message
      @action_status = status
      false
    end

    def parent_policy
      return if record.try(:parent).blank?

      @parent_policy ||= Pundit.policy(user_context, record.parent)
    end

    def sanitize_array_attribute(attr)
      [attr, attr => []]
    end

    def sanitize_attribute(attr)
      attr
    end

    def sanitized_attributes(attributes, opts)
      if opts[:nested]
        attributes.map(&method(:sanitize_nested_attribute))
      elsif opts[:array]
        attributes.map(&method(:sanitize_array_attribute))
      else
        attributes.map(&method(:sanitize_attribute))
      end
    end

    def sanitize_nested_attribute(key) # rubocop:disable Metrics/AbcSize
      association = record.class.reflect_on_association(key)

      return nil if association.blank? || (!association.polymorphic? && !association.klass)

      nested_attributes =
        if association.polymorphic?
          Pundit.policy(user_context, record).try("#{association.name}_attributes") || []
        else
          child = record.build_child(association.klass, user_context: user_context)
          Pundit.policy(user_context, child).permitted_attributes
        end

      {"#{key}_attributes" => nested_attributes + %i[id _destroy]}
    end

    module ClassMethods
      def condition_for(attr, pass, **shape_opts)
        raise("#{attr} not permitted by #{self}") if attribute_options(attr).blank? && pass.permission_required?

        alternatives = node_shapes_for(attr, **shape_opts)
        if alternatives.count == 1
          Condition.new(shape: alternatives.first, pass: pass)
        elsif alternatives.count.positive?
          Condition.new(shape: SHACL::NodeShape.new(or: alternatives), pass: pass)
        else
          pass
        end
      end

      def policy_class
        @policy_class ||= name.sub(/Policy/, '').classify.safe_constantize
      end

      def permitted_attributes
        initialize_permitted_attributes

        _permitted_attributes
      end

      private

      def attribute_options(attr)
        permitted_attributes.select { |opts| opts[:attributes].include?(attr) }
      end

      def condition_alternatives(attr)
        attribute_options(attr)
          .select { |opts| opts[:conditions].present? }
          .map { |opts| opts[:conditions] }
      end

      def node_shapes_for(attr, property: [], sh_not: [])
        alternatives = condition_alternatives(attr)
        alternatives = [[]] if alternatives.empty? && (property.any? || sh_not.any?)

        alternatives.map do |props|
          properties = property_shapes(props) + property
          SHACL::NodeShape.new(property: properties, sh_not: sh_not)
        end
      end

      def initialize_permitted_attributes
        return if _permitted_attributes && method(:_permitted_attributes).owner == singleton_class

        self._permitted_attributes = superclass.try(:_permitted_attributes)&.dup || []
      end

      def permit_attributes(attrs, **conditions)
        permitted_attributes << {attributes: attrs, conditions: conditions, options: {}}
      end

      def permit_array_attributes(attrs, **conditions)
        permitted_attributes << {attributes: attrs, conditions: conditions, options: {array: true}}
      end

      def permit_nested_attributes(attrs, **conditions)
        permitted_attributes << {attributes: attrs, conditions: conditions, options: {nested: true}}
      end

      def property_shapes(conditions)
        conditions.map { |key, options| send("#{key}_shapes", options) }.flatten.compact
      end
    end
  end
end
