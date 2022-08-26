# frozen_string_literal: true

module LinkedRails
  class Form
    class Field
      class FileInput < Field
        attr_writer :max_size

        def max_size
          @max_size.respond_to?(:call) ? @max_size.call : @max_size
        end
      end
    end
  end
end
