# frozen_string_literal: true

module LinkedRails
  class EnumValue
    include ActiveModel::Model
    include LinkedRails::Model

    attr_accessor :attr, :close_match, :exact_match, :group_by, :key, :klass, :type
    attr_writer :iri, :label

    def label
      label_from_variable ||
        I18n.t(
          "activerecord.attributes.#{class_name}.#{attr.to_s.pluralize}",
          default: [:"#{class_name.tableize}.#{attr}.#{key}", key.to_s.humanize]
        )
    end

    def iri(_opts = {})
      @iri || iri_with_root(RDF::URI("/enums/#{klass.name.tableize}/#{attr}##{key}"))
    end

    def rdf_type
      type
    end

    def to_param
      key
    end

    private

    def class_name
      klass.to_s.underscore
    end

    def label_from_variable
      @label.respond_to?(:call) ? @label.call : @label
    end
  end
end
