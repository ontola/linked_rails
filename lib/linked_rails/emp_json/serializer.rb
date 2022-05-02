# frozen_string_literal: true

require_relative 'constants'
require_relative 'base'
require_relative 'inclusion'
require_relative 'records'
require_relative 'sequence'
require_relative 'rdf_list'
require_relative 'fields'
require_relative 'slices'
require_relative 'primitives'

module LinkedRails
  module EmpJSON
    module Serializer
      extend ActiveSupport::Concern

      include LinkedRails::EmpJSON::Constants
      include LinkedRails::EmpJSON::Base
      include LinkedRails::EmpJSON::Inclusion
      include LinkedRails::EmpJSON::Records
      include LinkedRails::EmpJSON::Sequence
      include LinkedRails::EmpJSON::RDFList
      include LinkedRails::EmpJSON::Fields
      include LinkedRails::EmpJSON::Slices
      include LinkedRails::EmpJSON::Primitives

      included do
        attr_accessor :symbolize
      end

      def initialize(resource, opts = {})
        self.symbolize = opts.delete(:symbolize)

        super
      end

      def dump(*args, **options)
        case args.first
        when :empjson
          render_emp_json
        else
          super(*args, **options)
        end
      end
    end
  end
end

RDF::Serializers::NilSerializer.include(LinkedRails::EmpJSON::Serializer)
RDF::Serializers::ListSerializer.include(LinkedRails::EmpJSON::Serializer)
