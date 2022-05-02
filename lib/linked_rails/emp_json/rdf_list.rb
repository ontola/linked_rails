# frozen_string_literal: true

module LinkedRails
  module EmpJSON
    module RDFList
      def add_rdf_list_to_slice(slice, **options)
        elem = options.delete(:resource)
        loop do
          list_item_to_record(slice, elem)

          break if elem.rest_subject == NS.rdfv.nil

          elem = elem.rest
        end
      end

      def list_item_to_record(slice, elem) # rubocop:disable Metrics/AbcSize
        rid = create_record(slice, elem)
        add_attribute_to_record(slice, rid, uri_to_symbol(NS.rdfv.type), NS.rdfv.List)
        first = elem.first.is_a?(RDF::Term) ? elem.first : record_id(elem.first)
        add_attribute_to_record(slice, rid, uri_to_symbol(NS.rdfv.first), first)
        add_attribute_to_record(slice, rid, uri_to_symbol(NS.rdfv.rest), elem.rest_subject)
      end
    end
  end
end
