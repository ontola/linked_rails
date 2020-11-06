# frozen_string_literal: true

require 'active_response'
require 'kaminari/activerecord'
require 'rdf'
require 'rdf/vocab'
require 'uri_template'
require 'nill_class_renderer'
require 'linked_rails/engine'
require 'linked_rails/iri_mapper'

module LinkedRails
  @model_classes = {}

  mattr_accessor :app_ns, default: RDF::Vocabulary.new('http://example.com/my_vocab#')
  mattr_accessor :whitelisted_spi_ips
  mattr_writer :host, :scheme

  def self.configurable_class(parent, klass, default: nil) # rubocop:disable Metrics/AbcSize
    method = :"#{[parent, klass.to_s.downcase].compact.join('_')}_class"
    default ||= "LinkedRails::#{[parent&.to_s&.camelize, klass.to_s.classify].compact.join('::')}"

    mattr_writer method, default: default
    define_singleton_method method do
      @model_classes[method] ||= class_variable_get("@@#{method}").constantize
    end
  end

  class << self
    delegate :opts_from_iri, :resource_from_iri, :resource_from_iri!, :resource_from_opts, to: :iri_mapper_class
    def host
      # rubocop:disable Style/ClassVars
      @@host ||= Rails.application.routes.default_url_options[:host]&.split('//')&.last || 'example.com'
      # rubocop:enable Style/ClassVars
    end

    def scheme
      @@scheme ||= Rails.application.routes.default_url_options[:protocol] || :http # rubocop:disable Style/ClassVars
    end

    def iri(opts = {})
      RDF::URI.new(**{scheme: LinkedRails.scheme, host: LinkedRails.host}.merge(opts))
    end
  end

  %i[collection entry_point vocabulary].each { |klass| configurable_class(nil, klass) }
  %i[filter sorting view infinite_view paginated_view].each { |klass| configurable_class(:collection, klass) }
  configurable_class(:actions, :item)
  configurable_class(:menus, :item)
  configurable_class(nil, :rdf_error, default: 'LinkedRails::RDFError')
  configurable_class(nil, :action_list_parent, default: 'ApplicationActionList')
  configurable_class(nil, :controller_parent, default: 'ApplicationController')
  configurable_class(nil, :form_parent, default: 'ApplicationForm')
  configurable_class(nil, :policy_parent, default: 'ApplicationPolicy')
  configurable_class(nil, :serializer_parent, default: 'ApplicationSerializer')
  configurable_class(nil, :iri_mapper, default: 'LinkedRails::IRIMapper')
end

require 'linked_rails/vocab'
require 'linked_rails/enhancements'
require 'linked_rails/model'
require 'linked_rails/enhanceable'
require 'linked_rails/helpers/delta_helper'
require 'linked_rails/helpers/ontola_actions_helper'
require 'linked_rails/helpers/resource_helper'
require 'linked_rails/callable_variable'
require 'linked_rails/controller'
require 'linked_rails/errors'
require 'linked_rails/policy'
require 'linked_rails/rdf_error'
require 'linked_rails/routes'
require 'linked_rails/serializer'
require 'linked_rails/translate'
