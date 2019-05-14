# frozen_string_literal: true

require 'pundit'

module LinkedRails
  module Actions
    class Item
      include ActiveModel::Model
      include ActiveModel::Serialization
      include LinkedRails::Model

      attr_accessor :list, :policy_arguments, :user_context, :submit_label
      attr_writer :target, :iri_path
      delegate :resource, to: :list, allow_nil: true

      %i[description result type policy label image url collection condition form completed
         tag http_method iri_template_opts favorite path policy_resource].each do |method|
        attr_writer method
        define_method method do
          var = instance_variable_get(:"@#{method}")
          value = var.respond_to?(:call) ? list.instance_exec(&var) : var
          return instance_variable_set(:"@#{method}", value) if value

          send("#{method}_fallback") if respond_to?("#{method}_fallback", true)
        end
      end

      def action_status
        return NS::SCHEMA[:CompletedActionStatus] if completed
        return NS::SCHEMA[:PotentialActionStatus] if policy_valid?
        return LinkedRails::NS::ONTOLA[:ExpiredActionStatus] if policy_expired?

        LinkedRails::NS::ONTOLA[:DisabledActionStatus]
      end

      def as_json(_opts = {})
        {}
      end

      def available?
        @condition.nil? || condition
      end

      def iri_path(_opts = {})
        value = @iri_path.respond_to?(:call) ? list.instance_exec(&@iri_path) : @iri_path
        return @iri_path = value if value

        @iri_path = "#{resource.iri_path.split('?').first}/#{path || tag}"
      end

      def target
        @target ||= EntryPoint.new(parent: self)
      end

      private

      def description_fallback
        LinkedRails.translate(:action, :description, self)
      end

      def label_fallback
        LinkedRails.translate(:action, :label, self)
      end

      def policy_expired?
        @policy_expired ||= policy && resource_policy.try(:expired?)
      end

      def policy_resource_fallback
        resource
      end

      def policy_valid?
        return false if policy_resource.blank?
        return true if policy.blank?

        @policy_valid ||= resource_policy.send(policy, *policy_arguments)
      end

      def resource_policy
        @resource_policy ||= Pundit.policy(user_context, policy_resource)
      end
    end
  end
end
