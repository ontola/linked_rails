# frozen_string_literal: true

module LinkedRails
  class Form
    class Field
      class ColorInput < LinkedRails::Form::Field
        def datatype
          NS::ONTOLA[:CssHexColor]
        end

        def pattern
          @pattern ||= /^#([a-f0-9]{3}){1,2}$/i
        end
      end
    end
  end
end
