# frozen_string_literal: true

module LinkedRails
  module SHACL
    class Shape < LinkedRails::Resource
      # Custom attributes
      attr_accessor :referred_shapes

      # SHACL attributes
      attr_accessor :deactivated,
                    :label,
                    :message,
                    :property,
                    :severity,
                    :sparql,
                    :target,
                    :target_class,
                    :target_node,
                    :target_objects_of,
                    :target_subjects_of

      def referred_shape_instances(user_context)
        @referred_shape_instances ||= referred_shapes&.map do |shape|
          if shape.is_a?(Class) && shape < LinkedRails::Form
            build_shape(shape, user_context)
          else
            shape
          end
        end
      end

      private

      def build_shape(shape, user_context)
        shape.new(form.target.build_child(shape.model_class), form.iri_template, user_context).shape
      end

      class << self
        def iri
          RDF::Vocab::SH.Shape
        end
      end
    end
  end
end
