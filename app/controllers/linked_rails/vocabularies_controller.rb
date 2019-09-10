# frozen_string_literal: true

module LinkedRails
  class VocabulariesController < ApplicationController
    active_response :show

    private

    def add_class_data(klass, iri) # rubocop:disable Metrics/AbcSize
      @graph << RDF::Statement.new(iri, RDF[:type], RDF::RDFS[:Class])
      add_subclasses(iri, klass)
      add_input_select_property(iri, klass)
      add_class_label(iri, klass)
      add_class_description(iri, klass)

      klass.predicate_mapping.each do |property_iri, value|
        @graph << RDF::Statement.new(property_iri, RDF[:type], RDF[:Property])
        add_property_label(property_iri, klass, value.name)
        add_property_icon(property_iri, value.options[:image])
      end
    end

    def add_class_description(iri, klass)
      I18n.available_locales.each do |locale|
        label = I18n.t("#{klass.name.tableize}.tooltips.info", default: nil, locale: locale)
        next if label.blank?

        @graph << RDF::Statement.new(iri, NS::SCHEMA[:description], RDF::Literal.new(label, language: locale))
      end
    end

    def add_class_label(iri, klass)
      I18n.available_locales.each do |locale|
        label = I18n.t("#{klass.name.tableize}.type", default: klass.name.underscore.humanize, locale: locale)

        @graph << RDF::Statement.new(iri, RDF::RDFS[:label], RDF::Literal.new(label, language: locale))
      end
    end

    def add_input_select_property(iri, klass)
      @graph << RDF::Statement.new(iri, NS::ONTOLA['forms/inputs/select/displayProp'], klass.input_select_property)
    end

    def add_property_icon(property_iri, icon)
      return if icon.blank?

      @graph << RDF::Statement.new(property_iri, NS::SCHEMA[:image], RDF::URI("http://fontawesome.io/icon/#{icon}"))
    end

    def add_property_label(property_iri, klass, name)
      I18n.available_locales.each do |locale|
        label = I18n.with_locale(locale) do
          I18n.t("#{klass.name.tableize}.properties.#{name}.label", default: nil) ||
            LinkedRails::SHACL::PropertyShape.new(model_name: klass.model_name, model_attribute: name).name
        end
        next if label.blank?

        @graph << RDF::Statement.new(property_iri, RDF::RDFS[:label], RDF::Literal.new(label, language: locale))
      end
    end

    def add_subclasses(iri, klass)
      parent =
        if klass.superclass == ApplicationRecord
          NS::SCHEMA[:Thing]
        else
          klass.superclass.iri
        end
      @graph << RDF::Statement.new(iri, RDF::RDFS[:subClassOf], parent.is_a?(Array) ? parent.first : parent)
    end

    def authorize_action; end

    def show_success
      respond_with_resource(resource: vocab_graph)
    end

    def vocab_graph
      @graph = ::RDF::Graph.new
      ApplicationRecord.descendants.each do |klass|
        iri = klass.iri.is_a?(Array) ? klass.iri.first : klass.iri
        add_class_data(klass, iri)
      end
      @graph
    end
  end
end
