# frozen_string_literal: true

module LinkedRails
  module Model
    module Serialization
      extend ActiveSupport::Concern

      module ClassMethods
        def input_select_property
          NS::SCHEMA[:name]
        end

        # The associations to preload when serializing multiple records
        def includes_for_serializer
          {}
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
          ActiveModel::Serializer.serializer_for(self)
            ._attributes_data
            .values
            .select { |value| value.options[:predicate].present? }
            .map { |value| [value.options[:predicate], value] }
        end

        def reflection_mapping
          ActiveModel::Serializer.serializer_for(self)
            ._reflections
            .values
            .select { |value| value.options[:predicate].present? }
            .map { |value| [value.options[:predicate], value] }
        end
      end
    end
  end
end
