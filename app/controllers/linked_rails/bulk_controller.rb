# frozen_string_literal: true

require 'benchmark'

module LinkedRails
  class BulkController < ApplicationController # rubocop:disable Metrics/ClassLength
    REQUEST_HEADERS = %w[HTTP_ACCEPT_LANGUAGE HTTP_AUTHORIZATION HTTP_FORWARDED HTTP_HOST HTTP_REFERER HTTP_USER_AGENT
                         HTTP_WEBSITE_IRI HTTP_X_DEVICE_ID HTTP_X_FORWARDED_FOR HTTP_X_FORWARDED_HOST
                         HTTP_X_FORWARDED_PROTO HTTP_X_FORWARDED_SSL HTTP_X_REAL_IP].freeze

    def show
      render json: authorized_resources

      print_timings
    end

    private

    def authorized_resource(opts)
      return response_for_wrong_host(opts) if wrong_host?(opts[:iri])

      include = opts[:include].to_s == 'true'

      response_from_request(include, RDF::URI(opts[:iri]))
    rescue StandardError => e
      handle_resource_error(opts, e)
    end

    def authorized_resources
      @authorized_resources ||=
        params
          .require(:resources)
          .map { |param| param.permit(:include, :iri) }
          .map(&method(:timed_authorized_resource))
    end

    def handle_resource_error(opts, error)
      unless Rails.env.production?
        Rails.logger.error(error)
        Rails.logger.error(error.backtrace.join("\n"))
      end

      resource_response(opts[:iri], status: 500)
    end

    def print_timings
      Rails.logger.debug(
        "\n  CPU        system     user+system real        inc   status  cache   iri\n" \
        "#{timings.join("\n")}\n" \
        "  User: #{current_user.class}(#{current_user.id})"
      )
    end

    def require_doorkeeper_token?
      false
    end

    def resource_response_body(iri, rack_body, status)
      return rack_body.body if rack_body.is_a?(ActionDispatch::Response::RackBody)

      error = error_resource(status, StandardError.new(I18n.t("status.#{status}")), iri)

      resource_body(error)
    end

    def resource_request(iri)
      env = resource_request_env(iri)
      req = ActionDispatch::Request.new(env)
      req.path_info = ActionDispatch::Journey::Router::Utils.normalize_path(req.path_info)
      req.env['Current-User'] = current_user
      req.env['Doorkeeper-Token'] = doorkeeper_token

      req
    end

    def resource_request_env(iri)
      path = sanitized_relative_path(iri.dup)
      opts = resource_request_headers(iri)
      Rack::MockRequest.env_for(path, opts)
    end

    def resource_request_headers(iri)
      fullpath = iri.query.blank? ? iri.path : "#{iri.path}?#{iri.query}"

      request.env.slice(*REQUEST_HEADERS).merge(
        'HTTP_ACCEPT' => 'application/hex+x-ndjson',
        'HTTP_OPERATOR_ARG_GRAPH' => 'true',
        'ORIGINAL_FULLPATH' => fullpath
      )
    end

    def resource_response(iri, **opts)
      {
        body: nil,
        cache: :private,
        iri: iri,
        status: 404
      }.merge(opts)
    end

    def response_for_wrong_host(opts)
      resource_response(opts[:iri])
    end

    def response_from_request(include, iri) # rubocop:disable Metrics/AbcSize
      status, headers, rack_body = Rails.application.routes.router.serve(resource_request(iri))
      cache_from_header = headers['Cache-Control']&.squish&.presence

      resource_response(
        iri.to_s,
        body: include ? resource_response_body(iri, rack_body, status) : nil,
        cache: %w[no-cache private public].include?(cache_from_header.to_s.downcase) ? cache_from_header : :private,
        language: response_language(headers),
        status: status
      )
    end

    def response_language(headers)
      headers['Content-Language'] || I18n.locale
    end

    def sanitized_relative_path(iri) # rubocop:disable Metrics/AbcSize
      iri.path = "#{iri.path}/" unless iri.path&.ends_with?('/')
      uri = URI(LinkedRails.iri.path.present? ? iri.to_s.split("#{LinkedRails.iri.path}/").last : iri)

      [uri.path, uri.query].compact.join('?')
    end

    def timings
      @timings ||= []
    end

    def timed_authorized_resource(resource)
      res = nil
      time = Benchmark.measure { res = authorized_resource(resource) }
      unless Rails.env.production?
        include = resource[:include].to_s.ljust(5)
        timings << "#{time.to_s[0..-2]} - #{include}  #{res[:status]}   #{res[:cache]} #{resource[:iri]}"
      end
      res
    end

    def wrong_host?(iri)
      !iri.starts_with?(LinkedRails.iri)
    end
  end
end
