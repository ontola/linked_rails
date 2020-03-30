# frozen_string_literal: true

module LinkedRails
  class Collection
    class Sorting < RDF::Node
      include ActiveModel::Serialization
      include ActiveModel::Model
      include LinkedRails::Model
      DATE_MIN = Date.new(1970, 1, 1)
      DATE_TIME_MIN = Time.new(1970, 1, 1).utc
      STRING_MIN = 0.chr
      STRING_MAX = 255.chr

      attr_accessor :association_class, :direction, :key

      def attribute_name
        @attribute_name ||= key_from_mapping || :created_at
      end

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      def default_value
        column = association_class.column_for_attribute(attribute_name)

        case column.type
        when :date
          direction == :asc ? DATE_MIN : Date.current
        when :datetime
          (direction == :asc ? DATE_TIME_MIN : Time.current.utc).iso8601(6)
        when :string, :text
          direction == :asc ? STRING_MIN : STRING_MAX
        else
          ActiveModel::Type::Integer.new(limit: column.limit).send(direction == :asc ? :min_value : :max_value)
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength

      def iri
        self
      end

      def sort_direction
        direction == :desc ? :lt : :gt
      end

      def sort_value
        {attribute_name => direction}
      end

      private

      def key_from_mapping
        if key == Vocab::ONTOLA[:primaryKey]
          association_class.try(:primary_key)
        else
          association_class.try(:predicate_mapping).try(:[], key)&.name
        end
      end

      class << self
        def from_array(association_class, array)
          array&.map do |sort|
            new(
              association_class: association_class,
              direction: sort[:direction]&.to_sym,
              key: sort[:key]
            )
          end
        end
      end
    end
  end
end
