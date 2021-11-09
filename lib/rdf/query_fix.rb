module QueryFix
  def initialize(*args, **options)
    return super unless args.length == 1 && args.first.is_a?(String) && args.first.include?('?')

    split_iri = args.first.split('?')

    super([split_iri[0], split_iri[1].gsub('+', '%20')].join('?'), **options)
  end
end

RDF::URI.prepend(QueryFix)
