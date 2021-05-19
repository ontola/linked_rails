# frozen_string_literal: true

module LinkedRails
  module Controller
    module MenuHelpers
      def app_menu_list
        @app_menu_list ||= AppMenuList.new(resource: nil, user_context: user_context)
      end

      def app_menu?
        request.path.start_with?('/menus')
      end

      def menu_includes
        [
          members: LinkedRails.menus_item_class.preview_includes + [
            menu_sequence: [
              members: LinkedRails.menus_item_class.preview_includes +
                [menu_sequence: [members: LinkedRails.menus_item_class.preview_includes]]
            ]
          ]
        ]
      end

      def menu_list
        app_menu? ? app_menu_list : parent_from_params&.menu_list(user_context)
      end

      def menu_list!
        menu_list || raise(ActiveRecord::RecordNotFound)
      end
    end
  end
end
