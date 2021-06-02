# frozen_string_literal: true

module LinkedRails
  class FormsController < LinkedRails.controller_parent_class
    active_response :show

    class << self
      def controller_class
        LinkedRails.form_parent_class
      end
    end
  end
end
