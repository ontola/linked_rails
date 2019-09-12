# frozen_string_literal: true

require 'rdf'

module LinkedRails
  module NS
    AS = RDF::Vocabulary.new('https://www.w3.org/ns/activitystreams#')
    DBO = RDF::Vocabulary.new('http://dbpedia.org/ontology/')
    DC = RDF::Vocabulary.new('http://purl.org/dc/terms/')
    FOAF = RDF::Vocabulary.new('http://xmlns.com/foaf/0.1/')
    LL = RDF::Vocabulary.new('http://purl.org/link-lib/')
    ONTOLA = ::RDF::Vocabulary.new('https://ns.ontola.io/')
    SCHEMA = RDF::Vocabulary.new('http://schema.org/')
    SH = RDF::Vocabulary.new('http://www.w3.org/ns/shacl#')
    SP = RDF::Vocabulary.new('http://spinrdf.org/sp#')
  end
end
