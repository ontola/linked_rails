# frozen_string_literal: true

module LinkedRails
  module Model
    module IRI
      extend ActiveSupport::Concern

      def anonymous_iri
        @anonymous_iri ||= RDF::Node.new
      end

      def anonymous_iri?
        self.class < ActiveRecord::Base && new_record? && @iri.blank?
      end

      # @return [RDF::URI].
      def iri(**opts)
        return anonymous_iri if anonymous_iri?
        return iri_with_root(root_relative_iri(**opts)) if opts.present?

        @iri ||= iri_with_root(root_relative_iri)
      end

      def iri_elements
        root_relative_iri.to_s&.split('?')&.first&.split('/')&.map(&:presence)&.compact&.presence
      end

      # @return [Hash]
      def iri_opts
        @iri_opts ||= {
          fragment: route_fragment,
          id: to_param
        }
      end

      def rdf_type
        self.class.iri
      end

      def reload(**_opts)
        @iri = nil
        super
      end

      # @return [RDF::URI]
      def root_relative_iri(**opts)
        return @root_relative_iri if opts.blank? && @root_relative_iri.present?

        root_relative_iri = RDF::URI(expand_iri_template(**iri_opts.merge(opts)))
        @root_relative_iri = root_relative_iri if opts.blank?

        root_relative_iri
      end

      # @return [String, Symbol]
      def route_fragment; end

      private

      # @return [String]
      def expand_iri_template(**args)
        iri_template.expand(args)
      end

      # @return [RDF::URI]
      def iri_with_root(root_relative_iri)
        iri = root_relative_iri.dup
        iri.scheme = LinkedRails.scheme
        iri.host = LinkedRails.host
        iri.path = iri.path.presence || '/'
        iri
      end

      # @return [URITemplate]
      def iri_template
        self.class.iri_template
      end

      # @return [URITemplate]
      def iri_template_expand_path(template_base, path)
        tokens = (template_base.is_a?(String) ? LinkedRails::URITemplate.new(template_base) : template_base).tokens

        ind = tokens.find_index do |t|
          t.is_a?(URITemplate::RFC6570::Expression::FormQuery) || t.is_a?(URITemplate::RFC6570::Expression::Fragment)
        end

        prefix = ind ? tokens[0...ind] : tokens
        suffix = ind ? tokens[ind..-1] : []
        LinkedRails::URITemplate.new([prefix, path, suffix].flatten.join)
      end

      # @return [URITemplate]
      def iri_template_with_fragment(template_base, fragment)
        LinkedRails::URITemplate.new("#{template_base.to_s.sub(/{#[\w]+}/, '').split('#').first}##{fragment}")
      end

      module ClassMethods
        def iri
          @iri ||= iri_namespace[iri_value] if iri_namespace
        end

        def iri_namespace
          return if self == ApplicationRecord

          superclass.try(:iri_namespace) ||
            (linked_rails_module? ? Vocab.ontola : Vocab.app)
        end

        def iri_value
          linked_rails_module? ? name.demodulize : name
        end

        def iri_template
          @iri_template ||= LinkedRails::URITemplate.new("/#{route_key}{/id}{#fragment}")
        end

        def iris_from_scope(scope)
          ids = ids_for_iris(scope).uniq
          ids.map { |id| LinkedRails.iri(path: iri_template.expand(id: id)) }
        end

        def ids_for_iris(scope)
          scope.pluck(:id)
        end

        def linked_rails_module?
          (Rails.version < '6' ? parents : module_parents).include?(LinkedRails)
        end

        def route_key
          try(:model_name)&.route_key || to_s.tableize
        end
      end
    end
  end
end
