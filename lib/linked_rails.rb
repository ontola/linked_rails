# frozen_string_literal: true

require 'active_response'
require 'active_model_serializers'
require 'kaminari'
require 'rdf'
require 'uri_template'
require 'linked_rails/engine'

module LinkedRails
  @model_classes = {}

  mattr_accessor :app_ns, default: RDF::Vocabulary.new('http://example.com/my_vocab#')
  mattr_writer :host, :scheme

  def self.host
    # rubocop:disable Style/ClassVars
    @@host ||= Rails.application.routes.default_url_options[:host]&.split('//')&.last || 'example.com'
    # rubocop:enable Style/ClassVars
  end

  def self.scheme
    @@scheme ||= Rails.application.routes.default_url_options[:protocol] || :http # rubocop:disable Style/ClassVars
  end

  def self.iri(opts = {})
    RDF::URI.new({scheme: LinkedRails.scheme, host: LinkedRails.host}.merge(opts))
  end

  %i[
    collection
    filter
    sorting
    view
    infinite_view
    paginated_view
  ].each do |klass|
    method = :"#{klass}_class"
    prefix = klass == :collection ? 'LinkedRails::' : 'LinkedRails::Collection::'

    mattr_writer method, default: "#{prefix}#{klass.to_s.classify}"

    define_singleton_method method do
      @model_classes[method] ||= class_variable_get("@@#{method}").constantize
    end
  end
end

require 'linked_rails/routes'
require 'linked_rails/ns'
require 'linked_rails/model'
require 'linked_rails/enhancements'
require 'linked_rails/helpers/ontola_actions_helper'
require 'linked_rails/resource'

require 'linked_rails/actions'
require 'linked_rails/collection'
require 'linked_rails/controller'
require 'linked_rails/entry_point'
require 'linked_rails/errors'
require 'linked_rails/shacl'
require 'linked_rails/form'
require 'linked_rails/media_object'
require 'linked_rails/menus'
require 'linked_rails/policy'
require 'linked_rails/property_query'
require 'linked_rails/sequence'
require 'linked_rails/serializer'
require 'linked_rails/translate'
require 'linked_rails/web_page'
require 'linked_rails/widget'
