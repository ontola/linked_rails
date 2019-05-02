# frozen_string_literal: true

module LinkedRails
  class Form
    class StepSerializer < SHACL::PropertyShapeSerializer
      attribute :url, predicate: NS::SCHEMA[:url]
    end
  end
end
