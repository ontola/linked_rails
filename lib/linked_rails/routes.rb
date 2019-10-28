# frozen_string_literal: true

module RailsLDRoutingHelper
  def initialize(entities, api_only, shallow, options = {})
    options[:path] ||= entities.to_s.classify.safe_constantize.try(:route_key)
    super
  end
end

ActionDispatch::Routing::Mapper::Resources::Resource.prepend(RailsLDRoutingHelper)
