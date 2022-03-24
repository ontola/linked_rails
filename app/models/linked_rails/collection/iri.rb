# frozen_string_literal: true

module LinkedRails
  class Collection
    module IRI
      DEFAULT_IRI_TEMPLATE_KEYS = %i[before%5B%5D display filter%5B%5D page page_size sort%5B%5D table_type title type].freeze

      extend ActiveSupport::Concern

      def iri_opts
        {
          parent_iri: parent_iri,
          display: @display,
          table_type: @table_type,
          title: @title,
          type: @type,
          page_size: @page_size,
          filter: self.class.filter_iri_opts(@filter),
          route_key: route_key,
          sort: self.class.sort_iri_opts(@sort)
        }.compact
      end

      def serialized_iri_template
        iri_template
          .to_s
          .gsub('{route_key}', iri_template_route_key)
          .gsub('{/parent_iri*}', iri_template_parent_iri)
      end

      private

      def iri_template_parent_iri
        parent&.iri&.to_s&.split('?')&.first || LinkedRails.iri
      end

      def iri_template_route_key
        route_key.to_s
      end

      class_methods do
        def iri
          [super, Vocab.as.Collection]
        end

        def filter_iri_opts(filters)
          return nil if filters.blank?

          Hash[
            filters.map do |key, values|
              predicate = key.is_a?(RDF::URI) ? key : association_class.predicate_for_key(key)
              [predicate, values]
            end
          ]
        end

        def generate_iri_template(iri_template_keys)
          URITemplate.new("{/parent_iri*}/{route_key}{?#{parse_iri_template_keys(iri_template_keys)}}")
        end

        def parse_iri_template_keys(keys)
          (DEFAULT_IRI_TEMPLATE_KEYS + keys).map { |k| k.to_s.ends_with?('%5B%5D') ? "#{k}*" : k.to_s }.join(',')
        end

        def sort_iri_opts(sortings)
          return nil if sortings.blank?

          Hash[sortings.map { |s| [s[:key], s[:direction]] }]
        end
      end
    end
  end
end
