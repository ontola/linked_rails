# frozen_string_literal: true

module LinkedRails
  class Form
    class Field
      class SelectInputSerializer < FieldSerializer
        attribute :grouped, predicate: Vocab.form[:groupedOptions]
      end
    end
  end
end
