# frozen_string_literal: true

require 'pundit'

require_relative 'controller/actions/items'
require_relative 'controller/collections'
require_relative 'controller/crud_defaults'
require_relative 'controller/resource_helper'

module LinkedRails
  module Controller
    include Pundit
    include LinkedRails::ActiveResponse::Controller::Actions
    include LinkedRails::ActiveResponse::Controller::Collections
    include LinkedRails::ActiveResponse::Controller::CrudDefaults
    include LinkedRails::ActiveResponse::Controller::ResourceHelper
  end
end
