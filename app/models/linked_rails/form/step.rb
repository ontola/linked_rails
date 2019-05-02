# frozen_string_literal: true

module LinkedRails
  class Form
    class Step < LinkedRails::SHACL::PropertyShape
      attr_accessor :url

      class << self
        def iri
          NS::ONTOLA[:FormStep]
        end
      end
    end
  end
end
