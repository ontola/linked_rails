# frozen_string_literal: true

module LinkedRails
  module Model
    module Enhancements
      extend ActiveSupport::Concern

      included do
        class_attribute :enhancements
        self.enhancements ||= {}
      end

      def enhanced_with?(enhancement)
        self.class.enhancements.include?(enhancement)
      end

      module ClassMethods
        # Adds an enhancement to a model and includes the Model module.
        def enhance(enhancement, opts = {})
          initialize_enhancements
          already_included = enhanced_with?(enhancement)

          self.enhancements[enhancement] = opts
          return if already_included

          enhance_routing(enhancement) if enhancement.const_defined?(:Routing) && enhanced_with?(enhancement, :Routing)
          include enhancement::Model if enhancement.const_defined?(:Model) && enhanced_with?(enhancement, :Model)
        end

        def enhanced_with?(enhancement, const = nil)
          return false unless self.enhancements.key?(enhancement)
          return true if const.nil?

          opts = self.enhancements[enhancement]

          return opts[:only].include?(const) if opts.key?(:only)

          !opts.key?(:except) || !opts[:except].include?(const)
        end

        def enhancement_modules(const)
          enhancements
            .select { |enhancement, _opts| enhancement.const_defined?(const) && enhanced_with?(enhancement, const) }
            .map { |enhancement, _opts| enhancement.const_get(const) }
        end

        private

        def enhance_routing(enhancement)
          LinkedRails::Enhancements::RouteConcerns.add_concern(enhancement)
        end

        def initialize_enhancements
          return if enhancements && method(:enhancements).owner == singleton_class

          self.enhancements = superclass.try(:enhancements)&.dup || {}
        end
      end
    end
  end
end
