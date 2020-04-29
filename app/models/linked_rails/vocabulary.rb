# frozen_string_literal: true

module LinkedRails
  class Vocabulary # rubocop:disable Metrics/ClassLength
    include ActiveModel::Model

    include LinkedRails::Model

    def graph
      self.class.graph
    end

    class << self
      def graph
        @graph || generate_graph
      end

      private

      def add_class_data(klass, iri)
        add_statement(RDF::Statement.new(iri, RDF[:type], RDF::RDFS[:Class]))
        add_subclasses(iri, klass)
        add_input_select_property(iri, klass)
        add_class_label(iri, klass)
        add_class_description(iri, klass)
        add_property_data(klass)
      end

      def add_class_description(iri, klass)
        I18n.available_locales.each do |locale|
          label = I18n.t("#{klass.name.tableize}.tooltips.info", default: nil, locale: locale)
          next if label.blank?

          add_statement(
            RDF::Statement.new(iri, RDF::Vocab::SCHEMA.description, RDF::Literal.new(label, language: locale))
          )
        end
      end

      def add_class_label(iri, klass)
        I18n.available_locales.each do |locale|
          label = I18n.t("#{klass.name.tableize}.type", default: klass.name.underscore.humanize, locale: locale)

          add_statement(RDF::Statement.new(iri, RDF::RDFS[:label], RDF::Literal.new(label, language: locale)))
        end
      end

      def add_input_select_property(iri, klass)
        add_statement(
          RDF::Statement.new(iri, Vocab::ONTOLA['forms/inputs/select/displayProp'], klass.input_select_property)
        )
      end

      def add_property_icon(property_iri, icon)
        return if icon.blank?

        add_statement(
          RDF::Statement.new(property_iri, RDF::Vocab::SCHEMA.image, RDF::URI("http://fontawesome.io/icon/#{icon}"))
        )
      end

      def add_property_data(klass)
        klass.predicate_mapping.each do |property_iri, value|
          add_statement(RDF::Statement.new(property_iri, RDF[:type], RDF[:Property]))
          add_property_label(property_iri, klass, value.key)
          add_property_icon(property_iri, value.image)
        end
      end

      def add_property_label(property_iri, klass, name)
        I18n.available_locales.each do |locale|
          next if property_label_present?(property_iri, locale)

          label = property_label(klass, name, locale)

          next if label.blank?

          add_statement(RDF::Statement.new(property_iri, RDF::RDFS[:label], RDF::Literal.new(label, language: locale)))
        end
      end

      def add_sh_in_options(form)
        form
          .property_shapes_attrs
          .select { |opts| opts[:sh_in].is_a?(Array) }
          .each { |opts| opts[:sh_in].each(&method(:dump_sh_in)) }
      end

      def add_statement(statement)
        @graph << statement
      end

      def add_subclasses(iri, klass)
        parent =
          if klass.superclass == ApplicationRecord
            RDF::Vocab::SCHEMA.Thing
          else
            klass.superclass.iri
          end
        add_statement(RDF::Statement.new(iri, RDF::RDFS[:subClassOf], parent.is_a?(Array) ? parent.first : parent))
      end

      def authorize_action; end

      def dump_sh_in(option)
        RDF::Serializers.serializer_for(option)
          .new(option, params: {scope: user_context})
          .triples
          .each(&method(:add_statement))
      end

      def generate_graph
        @graph = ::RDF::Graph.new

        ApplicationRecord.descendants.each do |klass|
          iri = klass.iri.is_a?(Array) ? klass.iri.first : klass.iri
          add_class_data(klass, iri)
        end
        LinkedRails::Form.descendants.each do |form|
          add_sh_in_options(form)
        end

        @graph
      end

      def property_label(klass, name, locale)
        I18n.with_locale(locale) do
          I18n.t(
            "properties.#{name}.label",
            default: I18n.t("#{klass.name.tableize}.properties.#{name}.label", default: nil)
          ) || LinkedRails::SHACL::PropertyShape.new(model_name: klass.model_name, model_attribute: name).name
        end
      end

      def property_label_present?(property_iri, locale)
        @graph.query([property_iri, RDF::RDFS[:label]]).any? do |statement|
          statement.object.language == locale
        end
      end

      def user_context; end
    end
  end
end
