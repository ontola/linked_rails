# frozen_string_literal: true

require 'pundit'

module LinkedRails
  module Actions
    class Item # rubocop:disable Metrics/ClassLength
      include ActiveModel::Model
      include LinkedRails::Model

      attr_accessor :inherit, :list, :one_click, :policy_arguments, :submit_label, :target_path, :target_query
      attr_writer :parent, :resource, :root_relative_iri, :user_context, :object,
                  :target
      delegate :user_context, to: :list, allow_nil: true
      collection_options(
        association_base: lambda {
          action_list = parent ? parent.action_list(user_context) : association_class.app_action_list(user_context)

          action_list.actions
        },
        display: :grid,
        title: -> { I18n.t('actions.plural') }
      )

      %i[condition description result type policy label image target_url collection form
         tag http_method favorite action_path policy_resource predicate resource].each do |method|
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
          if policy_valid?
            Vocab.schema.PotentialActionStatus
          elsif policy_status
            policy_status
          elsif policy_expired?
            Vocab.ontola[:ExpiredActionStatus]
          else
            Vocab.ontola[:DisabledActionStatus]
          end
      end

      def as_json(**_opts)
        {}
      end

      def available?
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

      def form_resource_includes
        return {} if included_object.nil?

        includes = included_object.class.try(:preview_includes)&.presence || []

        (includes.is_a?(Hash) ? [includes] : includes) + (built_associations || [])
      end

      def included_object
        object if object&.iri&.anonymous?
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
        resource_policy.try(:message) unless policy_valid?
      end

      def root_relative_iri(**_opts)
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

      def policy_status
        resource_policy.try(:action_status)
      end

      def iri_opts
        return {} if resource.blank?

        resource.try(:singular_resource?) ? resource.singular_iri_opts : resource.iri_opts
      end

      def iri_template
        path_suffix = "/#{action_path || tag}"

        return @iri_template ||= LinkedRails::URITemplate.new(path_suffix) if resource.blank?

        base_template = resource.send(resource.try(:singular_resource?) ? :singular_iri_template : :iri_template)
        @iri_template ||= iri_template_expand_path(
          base_template.to_s.sub('display,', '').sub('sort%5B%5D*,', ''),
          path_suffix
        )
      end

      def rdf_type
        type
      end

      def target
        @target ||= LinkedRails.entry_point_class.new(parent: self)
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

      def target_url_fallback # rubocop:disable Metrics/AbcSize
        base = (resource.try(:singular_resource?) ? resource.singular_iri : resource.iri).dup
        base.path = "#{base.path}/#{target_path}" if target_path.present?
        base.query = Rack::Utils.parse_nested_query(base.query).merge(target_query).to_param if target_query.present?
        base
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
          parent = parent_from_params!(params, user_context) if params.key?(:parent_iri)

          default_collection_option(:collection_class).collection_or_view(
            default_collection_options.merge(parent: parent),
            index_collection_params(params, user_context)
          )
        end

        def requested_single_resource(params, user_context)
          return nil if params[:id].blank?

          parent = parent_from_params!(params, user_context) if params.key?(:parent_iri)
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
