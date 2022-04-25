# frozen_string_literal: true

module LinkedRails
  class ParamsParser # rubocop:disable Metrics/ClassLength
    attr_accessor :params, :graph, :user_context

    def initialize(graph: nil, params: {}, user_context: nil)
      self.graph = graph
      self.params = params
      self.user_context = user_context
    end

    def attributes_from_filters(klass)
      ActionController::Parameters.new(
        collection_params_parser.filter_params.each_with_object({}) do |(predicate, value), hash|
          key_and_value = filter_to_param(klass, predicate, value)
          hash[key_and_value.first] = key_and_value.second if key_and_value
        end
      )
    end

    def parse_param(klass, predicate, object)
      field_options = serializer_field(klass, predicate)
      if field_options.is_a?(FastJsonapi::Attribute)
        parse_attribute(klass, field_options, object.value)
      elsif field_options.is_a?(FastJsonapi::Relationship)
        parse_association(klass, field_options, object)
      end
    end

    # Recursively parses a resource from graph
    def parse_resource(subject, klass)
      graph
        .query([subject])
        .map { |statement| parse_statement(statement, klass) }
        .compact
        .reduce({}) { |h, (k, v)| add_param(h, k, v) }
    end

    private

    def add_param(hash, key, value) # rubocop:disable Metrics/MethodLength
      case hash[key]
      when nil
        hash[key] = value
      when Hash
        hash[key].merge!(value)
      when Array
        hash[key].append(value)
      else
        hash[key] = [hash[key], value]
      end
      hash
    end

    def associated_class_from_params(reflection, object)
      return reflection.klass unless reflection.polymorphic?

      query = graph.query(subject: object, predicate: Vocab.rdfv[:type])

      raise("No type given for '#{object}' referenced by polymorphic association '#{reflection.name}'") if query.empty?

      iri_to_class(query.first.object)
    end

    def collection_params_parser
      @collection_params_parser ||= LinkedRails::CollectionParamsParser.new(params.merge(user_context: user_context))
    end

    def filter_to_param(klass, predicate, value)
      options = serializer_field(klass, predicate)
      return unless value.count == 1 && options.present?

      parsed_value = value.first.start_with?('http') ? RDF::URI(value.first) : RDF::Literal(value.first)
      parse_param(
        klass,
        options.predicate,
        parsed_value
      )
    end

    def foreign_key_for_reflection(reflection)
      if reflection.options[:through]
        reflection.has_one? ? "#{reflection.name}_id" : "#{reflection.name.to_s.singularize}_ids"
      elsif reflection.belongs_to?
        reflection.foreign_key
      end
    end

    def iri_to_class(iri)
      iri.to_s.split(Vocab.app.to_s).pop&.classify&.safe_constantize ||
        LinkedRails.linked_models.detect { |klass| klass.iri == iri }
    end

    def nested_attributes(object, klass, association, collection)
      nested_resources =
        if graph.query([object, Vocab.rdfv[:first], nil]).present?
          nested_attributes_from_list(object, klass)
        else
          parsed = parse_nested_resource(object, klass)
          collection ? {rand(1_000_000_000).to_s => parsed} : parsed
        end
      ["#{association}_attributes", nested_resources]
    end

    def nested_attributes_from_list(object, klass)
      Hash[
        RDF::List.new(subject: object, graph: graph)
          .map { |nested| [rand(1_000_000_000).to_s, parse_nested_resource(nested, klass)] }
      ]
    end

    def parse_association(klass, field_options, object)
      association = field_options.association || field_options.key
      reflection = klass.reflect_on_association(association) || raise("#{association} not found for #{name}")

      if graph&.has_subject?(object)
        association_klass = associated_class_from_params(reflection, object)
        nested_attributes(object, association_klass, association, reflection.collection?)
      elsif object.iri?
        parse_iri_param(object, reflection)
      end
    end

    def parse_attribute(klass, field_options, value)
      parsed_value = parse_blob_attribute(value) || parse_enum_attribute(klass, field_options.key, value) || value

      [field_options.key, parsed_value]
    end

    def parse_blob_attribute(value)
      params["<#{value}>"] if value.starts_with?(Vocab.ll['blobs/'])
    end

    def parse_enum_attribute(klass, key, value)
      opts = RDF::Serializers.serializer_for(klass)&.enum_options(key)
      return if opts.blank?

      opts.detect { |_k, options| options.iri == value }&.first&.to_s
    end

    def parse_iri_param(iri, reflection)
      resource = LinkedRails.iri_mapper.resource_from_iri(iri, user_context)
      return unless resource

      key = foreign_key_for_reflection(reflection)

      value = resource&.try(reflection.association_primary_key) if key

      [key, value] if value
    end

    def parse_nested_resource(object, klass)
      resource = parse_resource(object, klass)
      resource[:id] ||= nested_resource_id(object)
      resource
    end

    def nested_resource_id(object)
      return unless object.iri?

      opts = LinkedRails.iri_mapper.opts_from_iri(object)
      if opts[:class].method(:requested_single_resource).owner == LinkedRails::Model::IRIMapping::ClassMethods
        opts[:params][:id]
      else
        opts[:class].requested_single_resource(opts[:params], nil)&.id
      end
    end

    def parse_statement(statement, klass)
      parse_param(klass, statement.predicate, statement.object)
    end

    def serializer_field(klass, predicate)
      field = klass.try(:predicate_mapping).try(:[], predicate)
      Rails.logger.info("#{predicate} not found for #{klass || 'nil'}") if field.blank?
      field
    end
  end
end
