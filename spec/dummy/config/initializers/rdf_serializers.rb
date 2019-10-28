# frozen_string_literal: true

require 'rdf/serializers/renderers'

RDF_CONTENT_TYPES = %i[nq].freeze

RDF::Serializers::Renderers.register(%i[nquads])
