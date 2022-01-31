# frozen_string_literal: true

module LinkedRails
  class Form
    class Page < LinkedRails::Resource
      attr_accessor :groups, :label, :description
      attr_writer :key

      def initialize(**attrs)
        super(**attrs)
        self.groups = []
      end

      def add_group(**opts)
        group = Form::Group.new(**opts)
        groups << group
        group
      end

      def footer_group
        @footer_group ||= add_group(collapsible: false, footer: true, key: :footer)
      end

      def footer_group!
        @footer_group
      end

      class << self
        def iri
          Vocab.form[:Page]
        end
      end
    end
  end
end
