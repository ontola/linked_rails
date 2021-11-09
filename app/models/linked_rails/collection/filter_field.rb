# frozen_string_literal: true

module LinkedRails
  class Collection
    class FilterField < RDF::Node
      include ActiveModel::Serialization
      include ActiveModel::Model
      include LinkedRails::Model
      include LinkedRails::CallableVariable

      attr_accessor :key, :klass, :collection
      attr_writer :options_array, :options_in
      callable_variable(:options_array)
      callable_variable(:options_in)

      def iri(**_opts)
        self
      end

      def options
        @options ||= options_array&.map(&method(:filter_option)) || []
      end

      def filter_option(option)
        attrs = option.is_a?(Hash) ? option : {value: option}
        Collection::FilterOption.new(attrs.merge(collection: collection, key: key))
      end

      def serializable?
        options_in || options_array
      end
    end
  end
end
