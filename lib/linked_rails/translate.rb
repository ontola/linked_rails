# frozen_string_literal: true

module LinkedRails
  def self.translate(*args)
    Translate.call(*args)
  end

  class Translate
    cattr_accessor :strategies, default: {}

    class << self
      def call(type, key, object)
        strategy_for(type, key).call(object)
      end

      def translations_for(type, key)
        strategies[type] ||= {}
        strategies[type][key] = ->(object) { yield(object) }
      end

      private

      def strategy_for(type, key)
        strategies[type] ||= {}
        strategies[type][key]
      end
    end
  end

  Translate.translations_for(:action, :label) do |object|
    I18n.t(
      "actions.#{object.resource&.class&.name&.tableize}.#{object.tag}.label",
      default: [:"actions.default.#{object.tag}.label", object.tag.to_s.humanize]
    )
  end

  Translate.translations_for(:action, :description) do |object|
    I18n.t(
      "actions.#{object.resource&.class&.name&.tableize}.#{object.tag}.description",
      default: [:"actions.default.#{object.tag}.description", '']
    )
  end

  Translate.translations_for(:property, :description) do |object|
    I18n.t(
      "properties.#{object.model_name&.to_s&.tableize}.#{object.model_attribute}.description",
      default: [:"actions.default.#{object.model_attribute}.description", '']
    )
  end

  Translate.translations_for(:property, :label) do |object|
    I18n.t(
      "properties.#{object.model_name&.to_s&.tableize}.#{object.model_attribute}.label",
      default: [:"actions.default.#{object.model_attribute}.label", object.model_attribute.to_s.humanize]
    )
  end
end
