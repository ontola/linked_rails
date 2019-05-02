# frozen_string_literal: true

module LinkedRails
  module Menus
    class List
      include ActiveModel::Model
      include LinkedRails::Model

      attr_accessor :resource
      class_attribute :defined_menus

      alias read_attribute_for_serialization send

      def menus
        defined_menus.map(&method(:menu_item))
      end

      def self.all
        []
      end

      def menu(tag)
        menu_item(tag, defined_menus[tag]) if defined_menus.key?(tag)
      end

      private

      def menu_item(tag, options) # rubocop:disable Metrics/AbcSize
        options[:label_params] ||= {}
        options[:label_params][:default] ||= ["menus.default.#{tag}".to_sym, tag.to_s.capitalize]
        options[:label] ||= I18n.t("menus.#{resource&.class&.name&.tableize}.#{tag}", options[:label_params])
        options.except!(:label_params)
        Item.new(resource: resource, tag: tag, parent: self, **options)
      end

      class << self
        def has_menu(tag, opts = {}) # rubocop:disable Naming/PredicateName
          initialize_menus
          defined_menus[tag] = opts
        end

        private

        def initialize_menus
          return if defined_menus && method(:defined_menus).owner == singleton_class

          self.defined_menus = superclass.try(:defined_menus)&.dup || {}
        end
      end
    end
  end
end
