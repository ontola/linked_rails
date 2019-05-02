# frozen_string_literal: true

require 'pundit'

require_relative 'controller/actions/items'
require_relative 'controller/collections'
require_relative 'controller/crud_defaults'

module LinkedRails
  module Controller
    include Pundit
    include LinkedRails::ActiveResponse::Controller::Actions
    include LinkedRails::ActiveResponse::Controller::Collections
    include LinkedRails::ActiveResponse::Controller::CrudDefaults
  end
end
