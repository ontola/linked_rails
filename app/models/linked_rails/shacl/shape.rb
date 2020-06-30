# frozen_string_literal: true

module LinkedRails
  module SHACL
    class Shape < LinkedRails::Resource
      # SHACL attributes
      attr_accessor(
        :and,
        :deactivated,
        :message,
        :node_kind,
        :or,
        :severity,
        :sh_not,
        :target_class,
        :target_objects_of,
        :target_subjects_of,
        :xone
      )
      attr_writer :target_node

      def target_node
        @target_node.respond_to?(:call) ? @target_node.call : @target_node
      end

      class << self
        def iri
          RDF::Vocab::SH.Shape
        end
      end
    end
  end
end
