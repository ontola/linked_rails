# frozen_string_literal: true

module LinkedRails
  module Model
    module Dirty
      def association_changed?(association)
        return false unless try(:association_cached?, association)

        if self.class.reflect_on_association(association).collection?
          send(association).any? { |a| a.previous_changes.present? }
        else
          send(association)&.previous_changes&.present?
        end
      end

      def previous_changes_by_predicate
        serializer_class = ActiveModel::Serializer.serializer_for(self)
        return {} unless respond_to?(:previous_changes) && serializer_class

        Hash[
          previous_changes
            .map { |k, v| [serializer_class._attributes_data[k.to_sym]&.options.try(:[], :predicate), v] }
            .select { |k, _v| k.present? }
        ]
      end

      def previously_changed_relations
        serializer_class = ActiveModel::Serializer.serializer_for(self)
        return {} unless serializer_class

        serializer_class._reflections.select do |key, _value|
          association_changed?(key.to_s.ends_with?('_collection') ? send(key).association : key)
        end
      end
    end
  end
end
