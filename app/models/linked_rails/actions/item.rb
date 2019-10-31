# frozen_string_literal: true

require 'pundit'

module LinkedRails
  module Actions
    class Item
      include ActiveModel::Model
      include ActiveModel::Serialization
      include LinkedRails::Model

      attr_accessor :exclude, :list, :policy_arguments, :submit_label
      attr_writer :parent, :target, :root_relative_iri, :user_context
      delegate :resource, :user_context, to: :list, allow_nil: true
      delegate :iri_opts, to: :resource, allow_nil: true

      %i[description result type policy label image url include_resource collection condition form completed
         tag http_method favorite path policy_resource predicate].each do |method|
        attr_writer method
        define_method method do
          var = instance_variable_get(:"@#{method}")
          value = var.respond_to?(:call) ? list.instance_exec(&var) : var
          return instance_variable_set(:"@#{method}", value) if value

          send("#{method}_fallback") if respond_to?("#{method}_fallback", true)
        end
      end

      def action_status
        return RDF::Vocab::SCHEMA.CompletedActionStatus if completed
        return RDF::Vocab::SCHEMA.PotentialActionStatus if policy_valid?
        return Vocab::ONTOLA[:ExpiredActionStatus] if policy_expired?

        Vocab::ONTOLA[:DisabledActionStatus]
      end

      def as_json(_opts = {})
        {}
      end

      def available?
        return false unless action_status == RDF::Vocab::SCHEMA.PotentialActionStatus

        @condition.nil? || condition
      end

      def included_resource
        resource if include_resource
      end

      def parent
        return @parent if instance_variable_defined?(:@parent)

        if resource.is_a?(LinkedRails.collection_class)
          resource.parent
        else
          resource
        end
      end

      def root_relative_iri(_opts = {})
        value = @root_relative_iri.respond_to?(:call) ? list.instance_exec(&@root_relative_iri) : @root_relative_iri
        value = RDF::URI(value) unless value.blank? || value.is_a?(RDF::URI)
        return @root_relative_iri = value if value

        super
      end

      def iri_template
        path_suffix = path.blank? ? "/actions/#{tag}" : "/#{path}"

        @iri_template ||= iri_template_expand_path(resource.send(:iri_template), path_suffix)
      end

      def target
        @target ||= LinkedRails.entry_point_class.new(parent: self)
      end

      def translation_key
        @translation_key ||= (resource.is_a?(Collection) ? resource.association_class : resource&.class)&.name&.tableize
      end

      def user_context
        @user_context || list.user_context
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

      def predicate_fallback
        Vocab::ONTOLA["#{tag}_action".camelize(:lower)]
      end

      def resource_policy
        @resource_policy ||= Pundit.policy!(user_context, policy_resource)
      end
    end
  end
end
