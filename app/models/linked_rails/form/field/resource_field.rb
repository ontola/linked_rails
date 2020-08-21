# frozen_string_literal: true

module LinkedRails
  class Form
    class Field
      class ResourceField < Field
        attr_writer :url

        def datatype; end

        def path
          @path
        end

        def permission_required?
          false
        end

        def url
          @url.respond_to?(:call) ? @url.call : @url
        end
      end
    end
  end
end
