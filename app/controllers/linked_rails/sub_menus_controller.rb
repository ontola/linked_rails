# frozen_string_literal: true

module LinkedRails
  class SubMenusController < LinkedRails.controller_parent_class
    include MenuHelpers

    active_response :index

    private

    def authorize_action; end

    def index_sequence
      @index_sequence ||= menu_list!.menu(menu_id).menu_sequence
    end

    def index_includes
      menu_includes
    end

    def menu_id
      params[:menu_id].to_sym
    end

    def params_for_parent
      super.except(:menu_id)
    end
  end
end
