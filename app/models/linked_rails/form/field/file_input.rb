# frozen_string_literal: true

module LinkedRails
  class Form
    class Field
      class FileInput < Field
        attr_accessor :max_size
      end
    end
  end
end
