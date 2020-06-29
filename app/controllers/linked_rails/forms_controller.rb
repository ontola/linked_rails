# frozen_string_literal: true

module LinkedRails
  class FormsController < ApplicationController
    active_response :show

    private

    def form_class
      LinkedRails::Form.descendants.detect do |klass|
        klass.to_s == [params[:module], "#{params[:id]&.singularize}_forms"].compact.join('/').classify
      end
    end

    def form_class!
      form_class || raise(ActiveRecord::RecordNotFound)
    end

    def requested_resource
      @requested_resource ||= form_class!.new
    end

    def show_includes
      [pages: {groups: :fields, footer_group: :fields}]
    end
  end
end
