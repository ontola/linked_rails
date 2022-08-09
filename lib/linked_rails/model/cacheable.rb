# frozen_string_literal: true

module LinkedRails
  module Model
    module Cacheable
      extend ActiveSupport::Concern

      included do
        if respond_to?(:after_commit)
          after_commit :publish_create, on: :create, if: :should_publish_changes
          after_commit :publish_update, on: :update, if: :should_publish_changes
          after_commit :publish_delete, on: :destroy, if: :should_publish_changes
        end
      end

      def cacheable?
        true
      end

      def publish_create
        publish_message('io.ontola.transactions.Created')
      end

      def publish_update
        publish_message('io.ontola.transactions.Updated')
      end

      def publish_delete
        publish_message('io.ontola.transactions.Deleted')
      end

      private

      def publish_message(type)
        LinkedRails::InvalidationStreamWorker.perform_now(type, iri.to_s, self.class.iri.to_s)
      rescue StandardError
        LinkedRails::InvalidationStreamWorker.perform_later(type, iri.to_s, self.class.iri.to_s)
      end

      def should_publish_changes
        cacheable? && !Rails.env.test?
      end
    end
  end
end
