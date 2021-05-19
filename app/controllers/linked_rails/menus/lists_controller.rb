# frozen_string_literal: true

module LinkedRails
  module Menus
    class ListsController < LinkedRails.controller_parent_class
      include MenuHelpers

      active_response :show, :index

      private

      def authorize_action; end

      def index_association
        menu_list!.menus
      end

      def index_includes_sequence
        menu_includes
      end

      def show_includes
        [menu_sequence: menu_includes]
      end

      def requested_resource
        @requested_resource ||= menu_list&.menu(params[:id]&.to_sym)
      end
    end
  end
end
