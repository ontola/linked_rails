# frozen_string_literal: true

module LinkedRails
  module Model
    module Dirty
      extend ActiveSupport::Concern

      included do
        def assign_nested_attributes_for_one_to_one_association(association_name, attributes)
          association_has_destructed(association_name) if will_destruct_association?(association_name, attributes)

          super
        end

        def assign_nested_attributes_for_collection_association(association_name, attrs)
          attributes = attrs
          attributes = attrs.with_indifferent_access.key?(:id) ? [attrs] : attrs.values if attrs.is_a?(Hash)

          association_has_destructed(association_name) if will_destruct_association?(association_name, attributes)

          super
        end
      end

      def previous_changes_by_predicate
        serializer_class = RDF::Serializers.serializer_for(self)
        return {} unless respond_to?(:previous_changes) && serializer_class

        Hash[
          previous_changes
            .map { |k, v| [serializer_class.attributes_to_serialize[k.to_sym]&.predicate, v] }
            .select { |k, _v| k.present? }
        ]
      end

      def previously_changed_relations
        serializer_class = RDF::Serializers.serializer_for(self)
        return {} unless serializer_class.try(:relationships_to_serialize)

        serializer_class.relationships_to_serialize.select do |key, _value|
          if respond_to?(key)
            association_key = key.to_s.ends_with?('_collection') ? send(key).association : key
            association_has_destructed?(association_key) || association_changed?(association_key)
          end
        end.with_indifferent_access
      end

      private

      def association_changed?(association)
        return true if previous_changes.include?("#{association}_id")
        return false unless try(:association_cached?, association)

        if self.class.reflect_on_association(association).collection?
          send(association).any? { |a| a.previous_changes.present? }
        else
          send(association)&.previous_changes&.present?
        end
      end

      def association_has_destructed(association_key)
        @destructed_association_members ||= []
        @destructed_association_members << association_key.to_sym
      end

      def association_has_destructed?(association_key)
        @destructed_association_members&.include?(association_key.to_sym)
      end

      def will_destruct_association?(association_name, attributes)
        return false unless nested_attributes_options[association_name][:allow_destroy]

        if attributes.is_a?(Array)
          attributes.any? { |attrs| has_destroy_flag?(attrs.with_indifferent_access) }
        else
          has_destroy_flag?(attributes.with_indifferent_access)
        end
      end
    end
  end
end
