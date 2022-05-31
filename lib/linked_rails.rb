# frozen_string_literal: true

require 'active_response'
require 'empathy/emp_json'
require 'jsonapi/serializer'
require 'kaminari/activerecord'
require 'rdf'
require 'rdf/list'
require 'rdf/query_fix'
require 'rdf/vocab'
require 'nill_class_renderer'
require 'linked_rails/engine'
require 'linked_rails/iri_mapper'
require 'linked_rails/collection_params_parser'
require 'linked_rails/params_parser'
require 'linked_rails/middleware/linked_data_params'
require 'linked_rails/middleware/error_handling'
require 'linked_rails/renderers'

module LinkedRails
  @model_classes = {}

  mattr_accessor :whitelisted_spi_ips
  mattr_writer :host, :scheme

  def self.configurable_class(parent, klass, default: nil, reader: nil) # rubocop:disable Metrics/AbcSize
    method = :"#{[parent, klass.to_s.downcase].compact.join('_')}_class"
    default ||= "LinkedRails::#{[parent&.to_s&.camelize, klass.to_s.classify].compact.join('::')}"

    mattr_writer method, default: default
    define_singleton_method reader || method do
      @model_classes[method] ||= class_variable_get("@@#{method}").constantize
    end
  end

  class << self
    def host
      # rubocop:disable Style/ClassVars
      @@host ||= Rails.application.routes.default_url_options[:host]&.split('//')&.last || 'example.com'
      # rubocop:enable Style/ClassVars
    end

    def linked_models
      @linked_models ||= ObjectSpace.each_object(Class).select do |c|
        c.included_modules.include?(LinkedRails::Model)
      end
    end

    def scheme
      @@scheme ||= Rails.application.routes.default_url_options[:protocol] || :http # rubocop:disable Style/ClassVars
    end

    def iri(**opts)
      RDF::URI.new(**{scheme: LinkedRails.scheme, host: LinkedRails.host}.merge(opts))
    end
  end

  configurable_class(:actions, :item)
  configurable_class(:collection, :filter)
  configurable_class(:collection, :sorting)
  configurable_class(:collection, :view)
  configurable_class(:collection, :infinite_view)
  configurable_class(:collection, :paginated_view)
  configurable_class(:menus, :item)
  configurable_class(:ontology, :class)
  configurable_class(:ontology, :property)
  configurable_class(nil, :action_list_parent, default: 'LinkedRails::Actions::List')
  configurable_class(nil, :collection)
  configurable_class(nil, :controller_parent, default: 'ApplicationController')
  configurable_class(nil, :current_user)
  configurable_class(nil, :entry_point)
  configurable_class(nil, :form_parent, default: 'ApplicationForm')
  configurable_class(nil, :iri_mapper, default: 'LinkedRails::IRIMapper', reader: :iri_mapper)
  configurable_class(nil, :manifest)
  configurable_class(nil, :ontology)
  configurable_class(nil, :policy_parent, default: 'ApplicationPolicy')
  configurable_class(nil, :rdf_error, default: 'LinkedRails::RDFError')
  configurable_class(nil, :serializer_parent, default: 'ApplicationSerializer')
end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'IRI'
  inflect.acronym 'RDF'
  inflect.acronym 'SHACL'
end

require 'linked_rails/uri_template'
require 'linked_rails/vocab'
require 'linked_rails/cache'
require 'linked_rails/enhancements'
require 'linked_rails/model'
require 'linked_rails/enhanceable'
require 'linked_rails/helpers/delta_helper'
require 'linked_rails/helpers/ontola_actions_helper'
require 'linked_rails/helpers/resource_helper'
require 'linked_rails/callable_variable'
require 'linked_rails/controller'
require 'linked_rails/policy'
require 'linked_rails/rdf_error'
require 'linked_rails/routes'
require 'linked_rails/serializer'
require 'linked_rails/translate'
require 'linked_rails/railtie'
