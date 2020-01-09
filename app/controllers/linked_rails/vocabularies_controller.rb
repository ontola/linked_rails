# frozen_string_literal: true

module LinkedRails
  class VocabulariesController < ApplicationController
    active_response :show

    private

    def requested_resource
      @requested_resource ||= LinkedRails.vocabulary_class.new
    end

    def show_success
      respond_with_resource(resource: current_resource)
    end
  end
end
