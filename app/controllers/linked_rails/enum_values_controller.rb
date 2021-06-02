# frozen_string_literal: true

module LinkedRails
  class EnumValuesController < LinkedRails.controller_parent_class
    active_response :index

    private

    def enum_options!
      serializer_class!.enum_options(params[:attribute]) || raise(ActiveRecord::RecordNotFound)
    end

    def requested_resource
      return super unless action_name == 'index'

      @requested_resource ||= LinkedRails::Sequence.new(
        enum_options!.values,
        id: index_iri,
        scope: LinkedRails::EnumValuePolicy::Scope
      )
    end

    def model_class
      @model_class ||= self.class.linked_models.detect do |klass|
        klass.to_s == ([params[:module]].compact + [params[:klass]&.singularize]).join('/').classify
      end
    end

    def model_class!
      model_class || raise(ActiveRecord::RecordNotFound)
    end

    def serializer_class
      @serializer_class ||= RDF::Serializers.serializer_for(model_class!)
    end

    def serializer_class!
      serializer_class || raise(ActiveRecord::RecordNotFound)
    end

    class << self
      def linked_models
        @linked_models ||= ObjectSpace.each_object(Class).select do |c|
          c.included_modules.include?(LinkedRails::Model)
        end
      end
    end
  end
end
