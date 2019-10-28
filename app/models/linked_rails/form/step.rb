# frozen_string_literal: true

module LinkedRails
  class Form
    class Step < LinkedRails::SHACL::PropertyShape
      attr_accessor :url

      def label
        @label.respond_to?(:call) ? form.instance_exec(&@label) : @label
      end

      class << self
        def iri
          Vocab::ONTOLA[:FormStep]
        end
      end
    end
  end
end
