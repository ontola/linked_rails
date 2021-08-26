# frozen_string_literal: true

module LinkedRails
  class ManifestsController < LinkedRails.controller_parent_class
    def show
      render json: current_resource.web_manifest
    end

    def tenant
      render json: {
        iri_prefix: LinkedRails.iri.host
      }
    end

    private

    def current_resource
      @current_resource ||= LinkedRails.manifest_class.new
    end
  end
end
