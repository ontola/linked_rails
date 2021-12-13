# frozen_string_literal: true

module LinkedRails
  class Form
    class Field
      class AssociationInputSerializer < FieldSerializer
        attribute :nested_form, predicate: Vocab.form[:form] do |object|
          object.nested_form.form_iri
        end
        has_one :target_class, predicate: Vocab.sh.targetClass
      end
    end
  end
end
