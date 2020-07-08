# frozen_string_literal: true

require 'rdf'

module LinkedRails
  module Vocab
    FHIR = RDF::Vocabulary.new('http://hl7.org/fhir/')
    FORM = RDF::Vocabulary.new('https://ns.ontola.io/form#')
    LIBRO = RDF::Vocabulary.new('https://ns.ontola.io/libro/')
    LL = RDF::Vocabulary.new('http://purl.org/link-lib/')
    ONTOLA = RDF::Vocabulary.new('https://ns.ontola.io/core#')
    SP = RDF::Vocabulary.new('http://spinrdf.org/sp#')
  end
end
