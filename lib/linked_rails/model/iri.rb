# frozen_string_literal: true

module LinkedRails
  module Model
    module Iri
      extend ActiveSupport::Concern

      def anonymous_iri
        @anonymous_iri ||= RDF::Node.new
      end

      def anonymous_iri?
        self.class < ActiveRecord::Base && new_record?
      end

      # @return [RDF::URI].
      def iri(opts = {})
        return anonymous_iri if anonymous_iri?
        return iri_with_root(root_relative_iri(opts)) if opts.present?

        @iri ||= iri_with_root(root_relative_iri)
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

      def reload(_opts = {})
        @iri = nil
        super
      end

      # @return [RDF::URI]
      def root_relative_iri(opts = {})
        RDF::URI(expand_iri_template(iri_opts.merge(opts)))
      end

      # @return [String, Symbol]
      def route_fragment; end

      private

      # @return [String]
      def expand_iri_template(args = {})
        iri_template.expand(args)
      end

      # @return [RDF::URI]
      def iri_with_root(root_relative_iri)
        iri = root_relative_iri.dup
        iri.scheme = LinkedRails.scheme
        iri.host = LinkedRails.host
        iri
      end

      # @return [URITemplate]
      def iri_template
        self.class.iri_template
      end

      # @return [URITemplate]
      def iri_template_expand_path(template_base, path)
        tokens = template_base.tokens

        ind = tokens.find_index do |t|
          t.is_a?(URITemplate::RFC6570::Expression::FormQuery) || t.is_a?(URITemplate::RFC6570::Expression::Fragment)
        end

        prefix = ind ? tokens[0...ind] : tokens
        suffix = ind ? tokens[ind..-1] : []
        URITemplate.new([prefix, path, suffix].flatten.join)
      end

      # @return [URITemplate]
      def iri_template_with_fragment(template_base, fragment)
        URITemplate.new("#{template_base.to_s.sub(/{#[\w]+}/, '').split('#').first}##{fragment}")
      end

      def singular_iri; end

      def singular_iri_opts
        {}
      end

      module ClassMethods
        def iri
          @iri ||= iri_namespace[iri_value]
        end

        def iri_namespace
          superclass.try(:iri_namespace) ||
            (linked_rails_module? ? Vocab.ontola : LinkedRails.app_ns)
        end

        def iri_value
          linked_rails_module? ? name.demodulize : name
        end

        def iri_template
          @iri_template ||= URITemplate.new("/#{route_key}{/id}{#fragment}")
        end

        def linked_rails_module?
          (Rails.version < '6' ? parents : module_parents).include?(LinkedRails)
        end

        delegate :route_key, to: :model_name
      end
    end
  end
end
