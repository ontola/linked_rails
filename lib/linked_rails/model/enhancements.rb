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
          return if enhanced_with?(enhancement)

          self.enhancements[enhancement] = opts
          enhance_routing(enhancement) if enhancement.const_defined?(:Routing)
          include enhancement::Model if enhancement.const_defined?(:Model)
        end

        def enhanced_with?(enhancement)
          self.enhancements.key?(enhancement)
        end

        def enhancement_modules(const)
          enhancements
            .select { |enhancement, opts| enhancement.const_defined?(const) && enhancement_module?(opts, const) }
            .map { |enhancement, _opts| enhancement.const_get(const) }
        end

        private

        def enhance_routing(enhancement)
          LinkedRails::Enhancements::RouteConcerns.add_concern(enhancement)
        end

        def enhancement_module?(opts, const)
          return opts[:only].include?(const) if opts.key?(:only)

          !opts.key?(:except) || !opts[:except].include?(const)
        end

        def initialize_enhancements
          return if enhancements && method(:enhancements).owner == singleton_class

          self.enhancements = superclass.try(:enhancements)&.dup || {}
        end
      end
    end
  end
end
