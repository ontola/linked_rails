# frozen_string_literal: true

module LinkedRails
  module Enhancements
    module Indexable
      module Model
        extend ActiveSupport::Concern

        module ClassMethods
          def root_collection(opts = {})
            return unless root_collection?

            LinkedRails.collection_class.new(root_collection_opts.merge(opts))
          end

          def root_collection?
            self < ActiveRecord::Base
          end

          def root_collection_opts
            {association_class: self}
          end
        end
      end
    end
  end
end
