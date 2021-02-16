# frozen_string_literal: true

module LinkedRails
  class Form
    class Field
      class SelectInputSerializer < FieldSerializer
        attribute :grouped, predicate: Vocab::FORM[:groupedOptions]
      end
    end
  end
end
