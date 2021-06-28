# frozen_string_literal: true

module LinkedRails
  module Model
    module Sorting
      extend ActiveSupport::Concern

      included do
        class_attribute :default_sortings, instance_accessor: false, instance_predicate: false
        self.default_sortings = [{key: Vocab.schema.dateCreated, direction: :desc}]
      end

      module ClassMethods
        def default_sort_column
          :created_at
        end
      end
    end
  end
end
