# frozen_string_literal: true

module LinkedRails
  class Form
    class OptionSerializer < ActiveModel::Serializer
      include LinkedRails::Serializer

      attribute :label, predicate: NS::SCHEMA[:name]
      delegate :type, to: :object
    end
  end
end
