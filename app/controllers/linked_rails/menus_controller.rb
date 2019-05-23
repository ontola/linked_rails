# frozen_string_literal: true

module LinkedRails
  class MenusController < LinkedRails.controller_parent_class
    active_response :show, :index

    skip_before_action :authorize_action

    private

    def app_menu_list
      @app_menu_list ||= AppMenuList.new(resource: current_user, user_context: user_context)
    end

    def app_menu?
      request.path.start_with?('/apex/')
    end

    def index_association
      menu_list.menus
    end

    def index_includes
      [menu_sequence: [members: [menu_sequence: :members]]]
    end

    def show_includes # rubocop:disable Metrics/MethodLength
      [
        menu_sequence: [
          members: LinkedRails.menus_item_class.preview_includes + [
            menu_sequence: [
              members: [
                LinkedRails.menus_item_class.preview_includes,
                menu_sequence: [members: LinkedRails.menus_item_class.preview_includes]
              ]
            ]
          ]
        ]
      ]
    end

    def menu_list
      app_menu? ? app_menu_list : parent_resource.menu_list(user_context)
    end

    def requested_resource
      @requested_resource ||= menu_list.menu(params[:id].to_sym)
    end
  end
end
