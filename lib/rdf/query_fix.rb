# frozen_string_literal: true

module QueryFix
  def initialize(*args, **options)
    if args.length == 1 && args.first.is_a?(String) && args.first.include?('?')
      split_iri = args.first.split('?')

      super([split_iri[0], split_iri[1].gsub('+', '%20')].join('?'), **options)
    else
      super
    end
  end
end

RDF::URI.prepend(QueryFix)
