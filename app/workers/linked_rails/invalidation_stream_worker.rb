# frozen_string_literal: true

module LinkedRails
  class InvalidationStreamWorker < ActiveJob::Base
    def perform(type, iri, resource_type)
      entry = {
        type: type,
        resource: iri,
        resourceType: resource_type
      }
      id = Storage.xadd(:stream, LinkedRails.cache_stream, entry)

      raise('No message id returned, implies failure') if id.blank?
    end
  end
end
