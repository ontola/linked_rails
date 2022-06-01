# frozen_string_literal: true

module LinkedRails
  class Form
    class Field
      class FileInputSerializer < FieldSerializer
        attribute :max_size, predicate: Vocab.form[:maxFileSize]
      end
    end
  end
end
