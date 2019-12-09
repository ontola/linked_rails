# frozen_string_literal: true

module LinkedRails
  class VocabulariesController < ApplicationController
    active_response :show

    private

    def show_success
      respond_with_resource(resource: LinkedRails.vocabulary_class.new)
    end
  end
end
