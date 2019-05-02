# frozen_string_literal: true

module LinkedRails
  class MenusController < ApplicationController
    active_response :show, :index

    private

    def application_menu?
      request.path.start_with?('/apex/')
    end

    def controller_class
      LinkedRails::Menus::List
    end

    def index_includes
      [menu_sequence: [members: [menu_sequence: :members]]]
    end

    def show_includes
      [
        menu_sequence: [
          members: Menus::Item.preview_includes + [
            menu_sequence: [
              members: [Menus::Item.preview_includes, menu_sequence: [members: Menus::Item.preview_includes]]
            ]
          ]
        ]
      ]
    end

    def index_association
      if parent_resource.present?
        parent_resource.menus
      else
        AppMenus.new(resource: current_user).menus
      end
    end

    def parent_resource
      @parent_resource ||= super unless application_menu?
    end

    def requested_resource
      @requested_resource ||=
        if parent_resource.present?
          parent_resource.menu(params[:id].to_sym)
        else
          AppMenus.new(resource: current_user).menu(params[:id].to_sym)
        end
    end

    def resource_by_id_parent; end

    def root_collection; end
  end
end
