# frozen_string_literal: true

module LinkedRails
  class Collection
    module Iri
      COLLECTION_PARAMS = %w[display filter%5B%5D* page page_size title type before%5B%5D* sort%5B%5D*].freeze
      attr_writer :canonical_iri_template, :iri_template

      def canonical_iri_template
        @canonical_iri_template ||=
          URITemplate.new(
            "#{[parent&.root_relative_canonical_iri, association_class.route_key].join('/')}"\
            "{?#{COLLECTION_PARAMS.join(',')}}"
          )
      end

      def iri_opts
        opts = {}
        iri_opts_add(opts, :display, display) if @display
        iri_opts_add(opts, :title, title) if @title
        iri_opts_add(opts, :type, type) if @type
        iri_opts_add(opts, :page_size, page_size) if @page_size
        iri_opts_add(opts, :'filter%5B%5D', filter_iri_opts)
        iri_opts_add(opts, :'sort%5B%5D', sort_iri_opts)
        opts
      end

      def iri_template
        @iri_template ||=
          URITemplate.new(
            [
              LinkedRails.iri,
              [parent&.root_relative_iri, association_class.route_key].join('/'),
              "{?#{COLLECTION_PARAMS.join(',')}}"
            ].join('')
          )
      end

      def iri_template_keys
        %i[display filter%5B%5D sort%5B%5D page_size title type]
      end

      def iri_template_opts
        opts = iri_opts.with_indifferent_access.slice(*iri_template_keys)
        Hash[opts.keys.map { |key| [CGI.unescape(key).sub('[]', ''), opts[key]] }].to_param
      end

      def filter_iri_opts
        @filter&.map do |key, values|
          predicate = key.is_a?(RDF::URI) ? key : association_class.predicate_for_key(key)

          values.map { |value| "#{CGI.escape(predicate.to_s)}=#{CGI.escape(value.to_s)}" }
        end&.flatten
      end

      def iri_opts_add(opts, key, value)
        opts[key] = value if value.present?
      end

      def sort_iri_opts
        sort&.map { |s| "#{CGI.escape(s[:key].to_s)}=#{s[:direction]}" }
      end

      class << self
        def iri
          [super, RDF::Vocab::AS.Collection]
        end
      end
    end
  end
end
