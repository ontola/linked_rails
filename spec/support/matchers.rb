# frozen_string_literal: true

module Matchers
  RSpec::Matchers.define :have_statement do |*expected|
    match do |actual|
      @actual = rdf_body(actual).statements

      @actual.include?(RDF::Statement.new(*expected))
    end

    diffable
  end

  def rdf_body(response)
    RDF::Repository.new << RDF::Reader.for(content_type: response.headers['Content-Type']).new(response.body)
  end
end
