# frozen_string_literal: true

module LinkedRails
  module Enhanceable
    def include_enhancements(klass_method, enhanceable)
      send(klass_method)
        .try(:enhancement_modules, enhanceable)
        &.reject { |mod| include? mod }
        &.each { |mod| include mod }
    end

    def enhanceable(klass_method, enhanceable)
      include_enhancements(klass_method, enhanceable)

      define_singleton_method('inherited') do |target|
        super(target)
        target.include_enhancements(klass_method, enhanceable) if target.name
      end
    end
  end
end
