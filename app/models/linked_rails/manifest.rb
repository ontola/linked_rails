# frozen_string_literal: true

module LinkedRails
  class Manifest
    include ActiveModel::Model
    include LinkedRails::Model

    def save
      Storage.hset(
        :persistent,
        :manifest,
        URL.as_href(LinkedRails.iri) => web_manifest.to_json
      )
    end

    def web_manifest
      web_manifest_base.merge(
        ontola: web_manifest_ontola_section,
        serviceworker: web_manifest_sw_section
      )
    end

    private

    def allowed_external_sources
      []
    end

    def app_name
      Rails.application.railtie_name.chomp('_application').humanize
    end

    def app_theme_color
      '#cc0000'
    end

    def background_color
      '#eef0f2'
    end

    def blob_preview_iri
      return unless ActiveStorage::Blob.service.present?

      "#{LinkedRails.iri(path: 'rails/active_storage/blobs/redirect')}/{signed_id}/preview')"
    end

    def blob_upload_iri
      return unless ActiveStorage::Blob.service.present?

      LinkedRails.iri(path: 'rails/active_storage/direct_uploads')
    end

    def css_class; end

    def csp_entries
      {
        connectSrc: [ActiveStorage::Blob.service.try(:bucket)&.url].compact,
        scriptSrc: [ActiveStorage::Blob.service.try(:bucket)&.url].compact
      }
    end

    def header_background
      :primary
    end

    def header_text
      :white
    end

    def icons
      []
    end

    def lang
      :nl
    end

    def scope
      LinkedRails.iri.to_s
    end

    def site_theme_color
      app_theme_color
    end

    def site_secondary_color
      '#262626'
    end

    def site_name
      app_name
    end

    def start_url
      scope == '/' ? scope : "#{scope}/"
    end

    def theme; end

    def theme_options
      {}
    end

    def web_manifest_base # rubocop:disable Metrics/MethodLength
      {
        background_color: background_color,
        dir: :rtl,
        display: :standalone,
        icons: icons,
        lang: lang,
        name: app_name,
        scope: scope,
        short_name: app_name,
        start_url: start_url,
        theme_color: site_theme_color
      }
    end

    def web_manifest_ontola_section # rubocop:disable Metrics/MethodLength
      {
        allowed_external_sources: allowed_external_sources,
        blob_preview_iri:  blob_preview_iri,
        blob_upload_iri: blob_upload_iri,
        csp: csp_entries,
        header_background: header_background,
        header_text: header_text,
        preconnect: preconnect,
        primary_color: site_theme_color,
        secondary_color: site_secondary_color,
        styled_headers: styled_headers,
        theme: theme,
        theme_options: theme_options.to_query,
        tracking: tracking,
        website_iri: LinkedRails.iri.to_s,
        websocket_path: websocket_path
      }
    end

    def web_manifest_sw_section
      {
        src: "#{scope.chomp('/')}/sw.js",
        scope: scope
      }
    end

    def websocket_path
      Rails.application.config.try(:action_cable).try(:mount_path).try(:[], 1..-1)
    end

    def preconnect
      []
    end

    def styled_headers
      false
    end

    def tracking
      []
    end

    class << self
      def destroy(iri)
        Storage.hdel(:persistent, :manifest, URL.as_href(iri))
      end

      def move(from, to)
        Storage.hset(
          :persistent,
          :redirect_prefix,
          URL.as_href(from) => URL.as_href(to)
        )

        data = Storage.hget(:persistent, :manifest, URL.as_href(from))

        Storage.hset(:persistent, :manifest, URL.as_href(to), data) if data

        destroy(from)
      end
    end
  end
end
