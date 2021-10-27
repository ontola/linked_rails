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

      def translation_key(resource)
        klass =
          case resource
          when Collection
            resource.association_class
          when Class
            resource
          else
            resource&.class
          end
        klass&.name&.demodulize&.tableize
      end

      def translations_for(type, key)
        strategies[type] ||= {}
        strategies[type][key] = ->(object, fallback) { yield(object, fallback) }
      end

      def key_for_iri(iri, key)
        [
          Vocab.for!(iri).__prefix__,
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
    result_class = object.list.send(:result_class)
    klass_iri = result_class.iri.is_a?(Array) ? result_class.iri.first : result_class.iri
    type = LinkedRails.translate(:class, :label, klass_iri)&.downcase

    I18n.t(
      "actions.#{Translate.translation_key(object.resource)}.#{object.tag}.description",
      default: [
        :"actions.default.#{object.tag}.description",
        fallback ? object.tag.to_s.humanize : ''
      ],
      type: type
    )
  end

  Translate.translations_for(:action, :label) do |object, fallback|
    result_class = object.list.send(:result_class)
    klass_iri = result_class.iri.is_a?(Array) ? result_class.iri.first : result_class.iri
    type = LinkedRails.translate(:class, :label, klass_iri)&.downcase

    I18n.t(
      "actions.#{Translate.translation_key(object.resource)}.#{object.tag}.label",
      default: [
        :"actions.default.#{object.tag}.label",
        fallback ? object.tag.to_s.humanize : ''
      ],
      type: type
    )
  end

  Translate.translations_for(:action, :submit) do |object, fallback|
    I18n.t(
      "actions.#{Translate.translation_key(object.resource)}.#{object.tag}.submit",
      default: [
        :"actions.default.#{object.tag}.submit",
        fallback ? object.tag.to_s.humanize : ''
      ]
    )
  end

  Translate.translations_for(:enum, :label) do |object|
    I18n.t(
      "enums.#{Translate.translation_key(object.klass)}.#{object.attr}.#{object.key}",
      default: [
        :"enums.#{object.attr}.#{object.key}",
        object.key.to_s.humanize
      ]
    )
  end

  Translate.translations_for(:field, :description) do |object, fallback|
    if object.model_attribute.present?
      I18n.t(
        "forms.#{Translate.translation_key(object.model_class)}.#{object.model_attribute}.description",
        default: [
          :"forms.default.#{object.model_attribute}.description",
          fallback ? object.model_attribute.to_s.humanize : ''
        ]
      ).presence
    end
  end

  Translate.translations_for(:field, :helper_text) do |object, fallback|
    if object.model_attribute.present?
      I18n.t(
        "forms.#{Translate.translation_key(object.model_class)}.#{object.model_attribute}.helper_text",
        default: [
          :"forms.default.#{object.model_attribute}.helper_text",
          fallback ? object.model_attribute.to_s.humanize : ''
        ]
      )
    end
  end

  Translate.translations_for(:field, :label) do |object, fallback|
    if object.model_attribute.present?
      I18n.t(
        "forms.#{Translate.translation_key(object.model_class)}.#{object.model_attribute}.label",
        default: [
          :"forms.default.#{object.model_attribute}.label",
          fallback ? object.model_attribute.to_s.humanize : ''
        ]
      ).presence
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
      default: (object.try(:label) || Translate.tag_for_iri(object)).to_s.underscore.humanize
    )
  end

  Translate.translations_for(:class, :plural_label) do |object|
    I18n.t(
      Translate.key_for_iri(object, :plural_label),
      default: (object.try(:label) || Translate.tag_for_iri(object)).to_s.tableize.humanize
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
      default: (object.try(:label) || Translate.tag_for_iri(object)).to_s.underscore.humanize
    )
  end
end
