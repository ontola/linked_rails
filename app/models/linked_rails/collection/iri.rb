# frozen_string_literal: true

module LinkedRails
  class Collection
    module Iri
      COLLECTION_PARAMS = %w[display filter%5B%5D* page page_size type before sort%5B%5D*].freeze

      def iri_opts # rubocop:disable Metrics/AbcSize
        opts = {}
        iri_opts_add(opts, :display, display)
        iri_opts_add(opts, :type, type) if type&.to_sym != default_type
        iri_opts_add(opts, :page_size, page_size) if page_size.to_i != default_page_size
        iri_opts_add(opts, :'filter%5B%5D', filter_iri_opts)
        iri_opts_add(opts, :'sort%5B%5D', sort_iri_opts)
        opts
      end

      def iri_path
        iri_template.expand(iri_opts)
      end

      def iri_template
        @iri_template ||=
          URITemplate.new(
            "#{[parent&.iri_path, association_class.route_key].compact.join('/')}{?#{COLLECTION_PARAMS.join(',')}}"
          )
      end

      def filter_iri_opts
        filter&.map { |key, value| "#{key}=#{value}" }
      end

      def iri_opts_add(opts, key, value)
        opts[key] = value if value.present?
      end

      def sort_iri_opts
        sort&.map { |key, value| "#{key}=#{value}" }
      end

      class << self
        def iri
          [super, NS::AS['Collection']]
        end
      end
    end
  end
end
