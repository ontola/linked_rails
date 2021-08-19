# frozen_string_literal: true

require 'pundit'

module LinkedRails
  module Actions
    class Item # rubocop:disable Metrics/ClassLength
      include ActiveModel::Model
      include LinkedRails::Model
      enhance LinkedRails::Enhancements::Singularable

      attr_accessor :list, :policy_arguments, :submit_label
      attr_writer :parent, :resource, :root_relative_iri, :user_context, :object,
                  :target, :translation_key
      delegate :user_context, to: :list, allow_nil: true

      %i[description result type policy label image url include_object include_paths collection condition form completed
         tag http_method favorite path policy_resource predicate resource].each do |method|
        attr_writer method
        define_method method do
          var = instance_variable_get(:"@#{method}")
          value = var.respond_to?(:call) ? list.instance_exec(&var) : var
          return instance_variable_set(:"@#{method}", value).presence if value

          send("#{method}_fallback") if respond_to?("#{method}_fallback", true)
        end
      end

      def action_status
        @action_status ||=
          if completed
            Vocab.schema.CompletedActionStatus
          elsif policy_valid?
            Vocab.schema.PotentialActionStatus
          elsif policy_expired?
            Vocab.ontola[:ExpiredActionStatus]
          else
            Vocab.ontola[:DisabledActionStatus]
          end
      end

      def as_json(_opts = {})
        {}
      end

      def available?
        return false unless action_status == Vocab.schema.PotentialActionStatus

        @condition.nil? || condition
      end

      def built_associations
        included_object
          .class
          .try(:reflect_on_all_associations)
          &.select { |association| included_object.association(association.name).loaded? }
          &.map(&:name)
      end

      def error
        policy_message ||
          I18n.t("actions.status.#{action_status.to_s.split('#').last}", default: nil)
      end

      def form_resource_includes # rubocop:disable Metrics/CyclomaticComplexity
        return {} if included_object.nil?
        return include_paths || {} if iri.anonymous?

        includes = included_object.class.try(:preview_includes)&.presence || []

        (includes.is_a?(Hash) ? [includes] : includes) + (built_associations || [])
      end

      def included_object
        object if include_object || object&.iri&.anonymous?
      end

      def object
        @object = list.instance_exec(&@object) if @object.respond_to?(:call)

        @object || resource
      end

      def parent
        return @parent if instance_variable_defined?(:@parent)

        if resource.is_a?(LinkedRails.collection_class)
          resource.parent
        else
          resource
        end
      end

      def policy_message
        resource_policy.try(:message) if action_status == Vocab.ontola[:DisabledActionStatus]
      end

      def root_relative_iri(_opts = {})
        value = root_relative_iri_from_var
        value = RDF::URI(value) unless value.blank? || value.is_a?(RDF::URI)
        return @root_relative_iri = value if value

        super
      end

      def root_relative_singular_iri
        value = root_relative_iri.to_s.sub(resource.root_relative_iri, resource.root_relative_singular_iri)

        RDF::URI(value)
      end

      def preview_includes
        [:target, included_object: form_resource_includes]
      end

      def singular_resource?
        resource.try(:singular_resource?)
      end

      def iri_opts
        resource&.iri_opts || {}
      end

      def iri_template
        path_suffix = path.blank? ? "/actions/#{tag}" : "/#{path}"

        return @iri_template ||= URITemplate.new(path_suffix) if resource.blank?

        @iri_template ||= iri_template_expand_path(resource.send(:iri_template), path_suffix)
      end

      def rdf_type
        type
      end

      def target
        @target ||= LinkedRails.entry_point_class.new(parent: self)
      end

      def translation_key
        @translation_key ||=
          (resource.is_a?(Collection) ? resource.association_class : resource&.class)&.name&.demodulize&.tableize
      end

      def user_context
        @user_context || list.user_context
      end

      private

      def description_fallback
        LinkedRails.translate(:action, :description, self, false)
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
        return true if policy.blank?
        return false if policy_resource.blank?

        @policy_valid ||= resource_policy.send(policy, *policy_arguments)
      end

      def predicate_fallback
        Vocab.ontola["#{tag}_action".camelize(:lower)]
      end

      def resource_fallback
        list&.resource
      end

      def resource_policy
        @resource_policy ||= Pundit.policy!(user_context, policy_resource) if policy_resource
      end

      def root_relative_iri_from_var
        return list.instance_exec(&@root_relative_iri) if @root_relative_iri.respond_to?(:call)

        @root_relative_iri
      end

      def type_fallback
        Vocab.schema.UpdateAction
      end

      class << self
        def app_action_list_class
          return @app_action_list_class if instance_variables.include?(:@app_action_list_class)

          @app_action_list_class = 'AppActionList'.safe_constantize
        end

        def app_action_list(user_context)
          app_action_list_class&.new(
            resource: nil,
            user_context: user_context
          )
        end

        def requested_index_resource(params, user_context)
          parent = parent_from_params(params, user_context)
          action_list = parent ? parent.action_list(user_context) : app_action_list(user_context)

          LinkedRails.collection_class.new(
            association_base: action_list.actions,
            association_class: ::Actions::Item,
            default_display: :grid,
            default_title: I18n.t('actions.plural'),
            parent: parent,
            title: params[:title]
          )
        end

        def requested_single_resource(params, user_context)
          return nil if params[:id].blank?

          parent = parent_from_params(params, user_context)
          action_list = parent ? parent.action_list(user_context) : app_action_list(user_context)

          action_list&.action(params[:id].to_sym)
        end

        def route_key
          :actions
        end
      end
    end
  end
end
