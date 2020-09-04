# frozen_string_literal: true

module LinkedRails
  class EnumValuesController < LinkedRails.controller_parent_class
    active_response :index

    private

    def index_association
      @index_association ||= policy_scope(
        serializer_class!.enum_options(params[:attribute]).values,
        policy_scope_class: LinkedRails::EnumValuePolicy::Scope
      )
    end

    def index_meta
      @index_meta ||= RDF::List.new(
        graph: RDF::Graph.new,
        subject: RDF::URI(request.original_url),
        values: index_association.map(&:iri)
      ).triples
    end

    def model_class
      @model_class ||= self.class.linked_models.detect do |klass|
        klass.to_s == ((params[:module] || []) + [params[:klass]&.singularize]).join('/').classify
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
