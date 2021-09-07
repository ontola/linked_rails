# frozen_string_literal: true

module LinkedRails
  class EnumValue
    include ActiveModel::Model
    include LinkedRails::Model

    attr_accessor :attr, :close_match, :exact_match, :group_by, :key, :klass, :type
    attr_writer :iri, :label

    def label
      label_from_variable || LinkedRails.translate(:enum, :label, self)
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

    def label_from_variable
      @label.respond_to?(:call) ? @label.call : @label
    end

    class << self
      def class_for_params(params)
        linked_models.detect do |klass|
          klass.to_s == ([params[:module]].compact + [params[:klass]&.singularize]).join('/').classify
        end
      end

      def enum_options(params)
        serializer_for_params(params)&.enum_options(params[:attribute])
      end

      def linked_models
        @linked_models ||= ObjectSpace.each_object(Class).select do |c|
          c.included_modules.include?(LinkedRails::Model)
        end
      end

      def requested_resource(opts, _user_context)
        options = enum_options(opts[:params])

        return unless options

        LinkedRails::Sequence.new(
          options.values,
          id: sanitized_sequence_iri(opts[:iri]),
          scope: LinkedRails::EnumValuePolicy::Scope
        )
      end

      def sanitized_sequence_iri(raw_iri)
        iri = RDF::URI(raw_iri)
        iri.query = nil
        iri.fragment = nil
        iri.path = iri.path.split('.').first
        iri
      end

      def serializer_for_params(params)
        klass = class_for_params(params)

        RDF::Serializers.serializer_for(klass) if klass
      end
    end
  end
end
