# frozen_string_literal: true

module LinkedRails
  class EntryPoint
    include ActiveModel::Model
    include LinkedRails::Model

    attr_accessor :parent
    attr_writer :url
    delegate :form, :description, :http_method, :image, :user_context,
             :resource, :tag, :translation_key, to: :parent

    def action_body
      return form if form.is_a?(RDF::URI)

      form&.form_iri
    end

    def as_json(_opts = {})
      {}
    end

    def iri_template
      @iri_template ||= iri_template_with_fragment(URITemplate.new(parent.root_relative_iri.to_s), :EntryPoint)
    end

    def label
      var = parent.submit_label
      value = var.respond_to?(:call) ? parent.list.instance_exec(&var) : var
      value || label_fallback
    end

    def url
      @url || parent.url
    end

    private

    def label_fallback
      LinkedRails.translate(:action, :submit, self)
    end

    def route_fragment
      :EntryPoint
    end

    class << self
      def iri
        Vocab.schema.EntryPoint
      end
    end
  end
end
