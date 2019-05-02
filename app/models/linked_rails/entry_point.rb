# frozen_string_literal: true

module LinkedRails
  class EntryPoint
    include ActiveModel::Model
    include ActiveModel::Serialization
    include LinkedRails::Model

    attr_accessor :parent
    delegate :form, :description, :url, :http_method, :image, :user_context, :resource, :tag, to: :parent

    def action_body
      @action_body ||= form&.new(target, user_context)&.shape
    end

    def as_json(_opts = {})
      {}
    end

    def iri_path
      iri = URI(parent.iri_path)
      iri.fragment = 'EntryPoint'
      iri.to_s
    end

    def label
      var = parent.submit_label
      value = var.respond_to?(:call) ? parent.list.instance_exec(&var) : var
      value || label_fallback
    end

    def target
      @target ||= parent.collection ? build_target : resource
    end

    private

    def build_target
      if resource.parent
        resource.parent.build_child(resource.association_class)
      else
        resource.association_class.new
      end
    end

    def label_fallback
      key = resource.is_a?(Collection) ? resource.association : resource&.class&.name&.tableize
      I18n.t(
        "actions.#{key}.#{tag}.submit",
        default: [:"actions.default.#{tag}.submit", :'actions.default.submit', 'save']
      )
    end

    def route_fragment
      :entrypoint
    end
  end
end
