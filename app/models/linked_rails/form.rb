# frozen_string_literal: true

require 'pundit'

module LinkedRails
  class Form # rubocop:disable Metrics/ClassLength
    include LinkedRails::Model

    class_attribute :pages, :model_class

    def iri
      self.class.form_iri
    end

    def canonical_iri
      iri
    end

    class << self
      def inherited(target)
        target.pages = []
      end

      def current_group
        @current_group || default_group
      end

      def current_page
        @current_page || default_page
      end

      def default_group
        @default_group ||= group(:default, collapsible: false)
      end

      def default_page
        @default_page ||= page(:default)
      end

      def field(key, opts = {})
        current_group.fields << Form::FieldFactory.new(
          field_options: opts,
          form: self,
          key: key
        ).condition_or_field
      end

      def footer
        @current_group = current_page.footer_group

        yield if block_given?

        @current_group = nil
        current_page.footer_group
      end

      def form_iri
        LinkedRails.iri(path: "/forms/#{to_s.sub('Form', '').tableize}")
      end

      def form_options_iri(attr)
        LinkedRails.iri(path: "/enums/#{model_class.to_s.tableize}/#{attr}")
      end

      def group(key, opts = {})
        opts[:collapsible] = true unless opts.key?(:collapsible)
        opts[:key] = key
        group = current_page.add_group(opts)
        @current_group = group

        yield if block_given?

        @current_group = nil
        group
      end

      # rubocop:disable Naming/PredicateName
      def has_many(key, opts = {})
        opts[:input_field] = Form::Field::AssociationInput
        opts[:max_count] = 99
        field(key, opts)
      end

      def has_one(key, opts = {})
        opts[:input_field] = Form::Field::AssociationInput
        opts[:max_count] = 1
        field(key, opts)
      end
      # rubocop:enable Naming/PredicateName

      def hidden(&block)
        group(:hidden, collapsible: false, hidden: true, &block)
      end

      def iri
        Vocab::FORM[:Form]
      end

      def model_class
        @model_class ||=
          name.sub(/Form$/, '').safe_constantize ||
          name.deconstantize.classify.sub(/Form$/, '').safe_constantize
      end

      def model_policy
        @model_policy ||= Pundit::PolicyFinder.new(model_class).policy
      end

      def model_policy!
        model_policy || raise("No policy found for #{model_class}")
      end

      def page(key, opts = {})
        page = Form::Page.new(opts.merge(key: key))
        @current_page = page
        pages << @current_page
        yield if block_given?
        @current_page = nil
        page
      end

      def resource(key, opts = {})
        opts[:input_field] = Form::Field::ResourceField
        field(key, opts)
      end

      def serializer_attributes
        @serializer_attributes ||= serializer_class&.attributes_to_serialize || {}
      end

      def serializer_class
        @serializer_class ||= RDF::Serializers.serializer_for(model_class)
      end

      def serializer_reflections
        @serializer_reflections ||= serializer_class&.relationships_to_serialize || {}
      end
    end
  end
end
