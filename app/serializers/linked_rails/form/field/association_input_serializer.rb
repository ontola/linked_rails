# frozen_string_literal: true

module LinkedRails
  class Form
    class Field
      class AssociationInputSerializer < FieldSerializer
        attribute :nested_form, predicate: Vocab::FORM[:form] do |object|
          object.nested_form.form_iri
        end
      end
    end
  end
end
