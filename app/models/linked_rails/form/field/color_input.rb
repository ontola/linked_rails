# frozen_string_literal: true

module LinkedRails
  class Form
    class Field
      class ColorInput < LinkedRails::Form::Field
        def datatype
          Vocab.ontola[:CssHexColor]
        end

        def pattern
          @pattern ||= /^#([a-f0-9]{3}){1,2}$/i
        end
      end
    end
  end
end
