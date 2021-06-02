# frozen_string_literal: true

module LinkedRails
  module Model
    module Serialization
      extend ActiveSupport::Concern

      alias read_attribute_for_serialization send

      module ClassMethods
        def attributes_from_filters(filters)
          filters.each_with_object({}) do |(key, value), hash|
            next unless value.count == 1

            attribute = predicate_mapping[key]&.key
            hash[attribute] = value.first if attribute
          end
        end

        def input_select_property
          RDF::Vocab::SCHEMA.name
        end

        # The associations to preload when serializing multiple records
        def includes_for_serializer
          {}
        end

        def predicate_for_key(key)
          return if key.blank?

          predicate_mapping.detect { |_key, value| value.key.to_sym == key.to_sym }&.first ||
            predicate_for_key(try(:attribute_aliases)&.key(key.to_s))
        end

        def predicate_mapping
          @predicate_mapping ||= Hash[attribute_mapping + reflection_mapping]
        end

        # The associations to include when serializing multiple records
        def preview_includes
          []
        end

        # The associations to include when serializing one record
        def show_includes
          preview_includes
        end

        private

        def attribute_mapping
          serializer = RDF::Serializers.serializer_for(self)
          return [] if serializer.try(:attributes_to_serialize).blank?

          serializer
            .attributes_to_serialize
            .values
            .select { |attr| attr.predicate.present? }
            .map { |attr| [attr.predicate, attr] }
        end

        def reflection_mapping
          serializer = RDF::Serializers.serializer_for(self)
          return [] if serializer.try(:relationships_to_serialize).blank?

          serializer
            .relationships_to_serialize
            .values
            .select { |value| value.predicate.present? }
            .map { |value| [value.predicate, value] }
        end
      end
    end
  end
end
