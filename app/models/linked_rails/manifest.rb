# frozen_string_literal: true

module LinkedRails
  class Manifest
    include ActiveModel::Model
    include LinkedRails::Model

    def app_name
      Rails.application.railtie_name.chomp('_application').humanize
    end

    def app_theme_color
      '#cc0000'
    end

    def background_color
      '#eef0f2'
    end

    def css_class; end

    def header_background
      :primary
    end

    def header_text
      :white
    end

    def preload_iris
      [
        scope,
        LinkedRails.iri(path: 'ns/core').to_s,
        LinkedRails.iri(path: 'c_a').to_s,
        LinkedRails.iri(path: 'menus').to_s
      ]
    end

    def scope
      @scope ||= LinkedRails.iri.to_s
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

    def theme; end

    def theme_options
      {}
    end

    def web_manifest
      web_manifest_base.merge(
        ontola: web_manifest_ontola_section,
        serviceworker: web_manifest_sw_section
      )
    end

    def web_manifest_base # rubocop:disable Metrics/MethodLength
      {
        background_color: background_color,
        dir: :rtl,
        display: :standalone,
        lang: :nl,
        name: app_name,
        scope: scope,
        short_name: app_name,
        start_url: scope,
        theme_color: site_theme_color
      }
    end

    def web_manifest_ontola_section # rubocop:disable Metrics/MethodLength
      {
        css_class: css_class,
        header_background: header_background,
        header_text: header_text,
        preload: preload_iris,
        primary_color: site_theme_color,
        secondary_color: site_secondary_color,
        theme: theme,
        theme_options: theme_options.to_query,
        website_iri: LinkedRails.iri,
        websocket_path: websocket_path
      }
    end

    def web_manifest_sw_section
      {
        src: "#{scope}/sw.js?manifestLocation=#{Rack::Utils.escape("#{scope}/manifest.json")}",
        scope: scope
      }
    end

    def websocket_path
      Rails.application.config.try(:action_cable).try(:mount_path).try(:[], 1..-1)
    end
  end
end
