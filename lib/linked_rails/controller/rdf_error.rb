# frozen_string_literal: true

module LinkedRails
  module Controller
    class RDFError
      attr_accessor :error, :requested_url, :status
      delegate :message, to: :error

      def initialize(status, requested_url, original_error)
        self.status = status
        self.error = original_error.is_a?(StandardError) ? original_error : original_error.new
        self.requested_url = ::RDF::URI(requested_url)
      end

      def graph
        g = ::RDF::Graph.new
        g << [requested_url, LinkedRails::NS::SCHEMA[:name], title] if title
        g << [requested_url, LinkedRails::NS::SCHEMA[:text], message]
        g << [requested_url, ::RDF[:type], type]
        g
      end

      private

      def title
        @title ||= I18n.t('status')[status] || I18n.t('status')[500]
      end

      def type
        @type ||= LinkedRails::NS::ONTOLA["errors/#{error.class.name.demodulize}Error"]
      end
    end
  end
end
