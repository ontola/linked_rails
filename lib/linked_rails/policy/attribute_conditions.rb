# frozen_string_literal: true

module LinkedRails
  module Policy
    module AttributeConditions
      extend ActiveSupport::Concern

      private

      def check_has_properties(properties)
        properties.all? { |k, v| @record.send(k).nil? != v }
      end

      def check_has_values(values)
        values.all? { |k, v| @record.send(k) == v }
      end

      def check_new_record(boolean)
        @record.new_record? == boolean
      end

      module ClassMethods
        private

        def has_properties_shapes(properties)
          properties.map do |key, boolean|
            SHACL::PropertyShape.new(
              path: policy_class.predicate_for_key(key),
              max_count: boolean ? nil : 0,
              min_count: boolean ? 1 : nil
            )
          end
        end

        def has_values_shapes(values)
          values.map do |key, value|
            enum = RDF::Serializers.serializer_for(policy_class).enum_options(key).try(:[], value)
            santized_value = enum ? -> { enum.iri } : value

            SHACL::PropertyShape.new(
              path: policy_class.predicate_for_key(key),
              has_value: santized_value
            )
          end
        end

        def new_record_shapes(boolean)
          has_properties_shapes(created_at: !boolean)
        end
      end
    end
  end
end
