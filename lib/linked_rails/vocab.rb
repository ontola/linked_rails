# frozen_string_literal: true

require 'rdf'

module LinkedRails
  module Vocab
    LL = RDF::Vocabulary.new('http://purl.org/link-lib/')
    ONTOLA = RDF::Vocabulary.new('https://ns.ontola.io/')
    SP = RDF::Vocabulary.new('http://spinrdf.org/sp#')
  end
end
