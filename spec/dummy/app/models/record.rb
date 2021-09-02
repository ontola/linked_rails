# frozen_string_literal: true

class Record < ApplicationRecord
  include LinkedRails::Model

  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Updatable

  belongs_to :parent, class_name: 'Record'
  has_many :children, class_name: 'Record', foreign_key: :parent_id

  with_collection :records

  attr_accessor :key, :key1, :key2, :key3
  filterable(
    Vocab.app[:key] => {
      filter: lambda { |scope, value|
        scope.where(actual_key: value)
      }
    },
    Vocab.app[:key2] => {},
    Vocab.app[:key3] => {
      filter: lambda { |scope, value|
        value ? scope.where.not(key3: nil) : scope.where(key3: nil)
      },
      values: [true, false]
    }
  )

  def self.default_per_page
    11
  end

  def body=(value)
    super(value.presence)
  end
end
