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

      def self.iri
        NS::SH[:Shape]
      end
    end
  end
end
