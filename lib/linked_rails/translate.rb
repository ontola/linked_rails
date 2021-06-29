# frozen_string_literal: true

module LinkedRails # rubocop:disable Metrics/ModuleLength
  def self.translate(*args)
    Translate.call(*args)
  end

  def self.translations(translation)
    I18n.available_locales.map do |locale|
      I18n.with_locale(locale) do
        value = translation.call
        RDF::Literal.new(value, language: locale) if value
      end
    end.compact
  end

  class Translate
    cattr_accessor :strategies, default: {}

    class << self
      def call(type, key, object, fallback = true)
        strategy_for(type, key).call(object, fallback)
      end

      def translations_for(type, key)
        strategies[type] ||= {}
        strategies[type][key] = ->(object, fallback) { yield(object, fallback) }
      end

      def key_for_iri(iri, key)
        [
          Vocab.for(iri).__prefix__,
          tag_for_iri(iri),
          key
        ].join('.')
      end

      def tag_for_iri(iri)
        iri.to_s.split(Vocab.for(iri).to_s).last
      end

      private

      def strategy_for(type, key)
        strategies[type] ||= {}
        strategies[type][key]
      end
    end
  end

  Translate.translations_for(:action, :description) do |object, fallback|
    I18n.t(
      "actions.#{object.translation_key}.#{object.tag}.description",
      default: [:"actions.default.#{object.tag}.description", fallback ? object.tag.to_s.humanize : '']
    )
  end

  Translate.translations_for(:action, :label) do |object, fallback|
    I18n.t(
      "actions.#{object.translation_key}.#{object.tag}.label",
      default: [:"actions.default.#{object.tag}.label", fallback ? object.tag.to_s.humanize : '']
    )
  end

  Translate.translations_for(:action, :submit) do |object, fallback|
    I18n.t(
      "actions.#{object.translation_key}.#{object.tag}.submit",
      default: [:"actions.default.#{object.tag}.submit", fallback ? object.tag.to_s.humanize : '']
    )
  end

  Translate.translations_for(:field, :description) do |object, fallback|
    if object.model_attribute.present?
      model_key = object.model_class&.to_s&.demodulize&.tableize

      I18n.t(
        "#{model_key}.properties.#{object.model_attribute}.description",
        default: [
          :"properties.#{model_key}.#{object.model_attribute}.description",
          :"actions.default.#{object.model_attribute}.description",
          :"properties.#{object.model_attribute}.description",
          fallback ? object.model_attribute.to_s.humanize : ''
        ]
      )
    end
  end

  Translate.translations_for(:field, :helper_text) do |object, fallback|
    if object.model_attribute.present?
      model_key = object.model_class&.to_s&.demodulize&.tableize

      I18n.t(
        "#{model_key}.properties.#{object.model_attribute}.helper_text",
        default: [
          :"properties.#{model_key}.#{object.model_attribute}.helper_text",
          :"actions.default.#{object.model_attribute}.helper_text",
          :"properties.#{object.model_attribute}.helper_text",
          fallback ? object.model_attribute.to_s.humanize : ''
        ]
      )
    end
  end

  Translate.translations_for(:field, :label) do |object, fallback|
    if object.model_attribute.present?
      model_key = object.model_class&.to_s&.demodulize&.tableize

      I18n.t(
        "#{model_key}.properties.#{object.model_attribute}.label",
        default: [
          :"properties.#{model_key}.#{object.model_attribute}.label",
          :"actions.default.#{object.model_attribute}.label",
          :"properties.#{object.model_attribute}.label",
          fallback ? object.model_attribute.to_s.humanize : ''
        ]
      )
    end
  end

  Translate.translations_for(:class, :description) do |object|
    I18n.t(Translate.key_for_iri(object, :description), default: nil)
  end

  Translate.translations_for(:class, :icon) do |object|
    I18n.t(Translate.key_for_iri(object, :icon), default: nil)
  end

  Translate.translations_for(:class, :label) do |object|
    I18n.t(
      Translate.key_for_iri(object, :label),
      default: (object.label || Translate.tag_for_iri(object)).to_s.underscore.humanize
    )
  end

  Translate.translations_for(:class, :plural_label) do |object|
    I18n.t(
      Translate.key_for_iri(object, :plural_label),
      default: (object.label || Translate.tag_for_iri(object)).to_s.tableize.humanize
    )
  end

  Translate.translations_for(:property, :description) do |object|
    I18n.t(Translate.key_for_iri(object, :description), default: nil)
  end

  Translate.translations_for(:property, :icon) do |object|
    I18n.t(Translate.key_for_iri(object, :icon), default: nil)
  end

  Translate.translations_for(:property, :label) do |object|
    I18n.t(
      Translate.key_for_iri(object, :label),
      default: (object.label || Translate.tag_for_iri(object)).to_s.underscore.humanize
    )
  end
end
