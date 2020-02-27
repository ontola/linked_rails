# frozen_string_literal: true

module LinkedRails
  module Enhancements
    class RouteConcerns
      cattr_accessor :enhancement_concerns, default: []

      class << self
        def add_concern(opts)
          enhancement_concerns << opts unless enhancement_concerns.include?(opts)
        end
      end
    end
  end
end

module ActionDispatch
  module Routing
    class Mapper
      def include_route_concerns(klass: @scope[:controller].classify.constantize, only: nil, except: [])
        include =
          if klass.respond_to?(:each)
            klass.map(&method(:route_concerns_for)).flatten.uniq
          else
            route_concerns_for(klass)
          end

        include &= only unless only.nil?
        include -= except

        concerns include
      end

      def add_missing_concern(enhancement)
        return if @concerns.include?(concern_key_from_enhancement(enhancement))

        module_parent_for(enhancement).route_concerns(self)
      end

      def concern_key_from_enhancement(enhancement)
        module_parent_for(enhancement).to_s.demodulize.underscore.to_sym
      end

      def route_concerns_for(klass)
        klass
          .enhancement_modules(:Routing)
          .each(&method(:add_missing_concern))
          .map(&method(:concern_key_from_enhancement))
      end

      def module_parent_for(klass)
        Rails.version < '6' ? klass.parent : klass.module_parent
      end
    end
  end
end
