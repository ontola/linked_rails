# frozen_string_literal: true

module LinkedRails
  module Errors
    class UnknownEmail < Doorkeeper::Errors::InvalidGrantReuse
      def initialize(_options = {})
        message = I18n.t('devise.failure.invalid_email')
        super(message)
      end
    end
  end
end
