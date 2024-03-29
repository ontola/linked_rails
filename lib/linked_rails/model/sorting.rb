# frozen_string_literal: true

module LinkedRails
  module Model
    module Sorting
      extend ActiveSupport::Concern

      module ClassMethods
        def default_sort_column
          :created_at
        end
      end
    end
  end
end
