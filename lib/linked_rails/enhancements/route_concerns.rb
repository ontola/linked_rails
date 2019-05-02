# frozen_string_literal: true

module LinkedRails
  module Enhancements
    class RouteConcerns
      cattr_accessor :enhancement_concerns, default: []

      class << self
        def add_concern(opts)
          enhancement_concerns << opts
        end
      end
    end
  end
end

module ActionDispatch
  module Routing
    class Mapper
      def include_route_concerns(only: nil, except: [])
        include =
          @scope[:controller]
            .classify
            .constantize
            .enhancement_modules(:Routing)
            .each(&method(:add_missing_concern))
            .map(&method(:concern_key_from_enhancement))
        include &= only unless only.nil?
        include -= except

        concerns include
      end

      def add_missing_concern(enhancement)
        return if @concerns.include?(concern_key_from_enhancement(enhancement))

        enhancement.parent.route_concerns(self)
      end

      def concern_key_from_enhancement(enhancement)
        enhancement.parent.to_s.demodulize.underscore.to_sym
      end
    end
  end
end
