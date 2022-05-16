# frozen_string_literal: true

module LinkedRails
  module EmpJSON
    module Primitives
      include EmpJSON::Constants

      AS_TIME_WITH_ZONE = Object.const_defined?('ActiveSupport::TimeWithZone') && Object.const_get('ActiveSupport::TimeWithZone')

      def object_to_value(value)
        return primitive_to_value(value.iri) if value.respond_to?(:iri)

        return primitive_to_value(value.subject) if value.is_a?(RDF::List)

        primitive_to_value(value)
      end

      def node_to_local_id(value)
        shorthand(EMP_TYPE_LOCAL_ID, "_:#{value.id}")
      end

      def primitive_to_value(value) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
        throw_unknown_ruby_object(value) if value.nil?

        return shorthand(EMP_TYPE_DATETIME, value.iso8601) if as_time_with_zone?(value)

        case value
        when RDF::Node
          node_to_local_id(value)
        when RDF::URI, URI
          shorthand(EMP_TYPE_GLOBAL_ID, value.to_s)
        when DateTime
          shorthand(EMP_TYPE_DATETIME, value.iso8601)
        when String
          shorthand(EMP_TYPE_STRING, value)
        when true, false
          shorthand(EMP_TYPE_BOOL, value.to_s)
        when Symbol
          primitive(NS.xsd.token, value.to_s)
        when Integer
          integer_to_value(value)
        when Float, Numeric
          use_rdf_rb_for_primitive(value)
        when RDF::Literal
          rdf_literal_to_value(value)
        else
          throw_unknown_ruby_object(value)
        end
      end

      def integer_to_value(value)
        size = value.bit_length
        if size <= 32
          shorthand(EMP_TYPE_INTEGER, value.to_s)
        elsif size > 32 && size <= 64
          shorthand(EMP_TYPE_LONG, value.to_s)
        else
          use_rdf_rb_for_primitive(value)
        end
      end

      def rdf_literal_to_value(value) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        case value.datatype
        when NS.rdfv.langString
          {
            type: EMP_TYPE_LANGSTRING,
            l: value.language.to_s,
            v: value.value
          }
        when NS.xsd.string
          shorthand(EMP_TYPE_STRING, value.value)
        when NS.xsd.dateTime
          shorthand(EMP_TYPE_DATETIME, value.value)
        when NS.xsd.boolean
          shorthand(EMP_TYPE_BOOL, value.value)
        when NS.xsd.integer
          integer_to_value(value.to_i)
        when NS.xsd.token
          primitive(NS.xsd.token, value.to_s)
        else
          throw 'unknown RDF::Literal'
        end
      end

      def use_rdf_rb_for_primitive(value)
        rdf = RDF::Literal(value)
        primitive(rdf.datatype.to_s, rdf.value)
      end

      def shorthand(type, value)
        {
          type: type,
          v: value
        }
      end

      def primitive(datatype, value)
        {
          type: EMP_TYPE_PRIMITIVE,
          dt: datatype,
          v: value
        }
      end

      def as_time_with_zone?(value)
        AS_TIME_WITH_ZONE && value.is_a?(AS_TIME_WITH_ZONE)
      end

      def throw_unknown_ruby_object(value)
        throw "unknown ruby object: #{value} (#{value.class})"
      end
    end
  end
end
