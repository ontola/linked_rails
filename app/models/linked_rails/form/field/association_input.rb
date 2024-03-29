# frozen_string_literal: true

module LinkedRails
  class Form
    class Field
      class AssociationInput < Field
        attr_writer :nested_form

        def datatype; end

        def nested_form
          @nested_form ||= target_class.form_class
        end

        def target_class
          return @target_class if @target_class

          klass_name.constantize unless form.abstract_form
        end

        private

        def klass_name
          @klass_name ||= form.model_class.try(:reflections).try(:[], key.to_s)&.class_name || key.to_s.classify
        end
      end
    end
  end
end
