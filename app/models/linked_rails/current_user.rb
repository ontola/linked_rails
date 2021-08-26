# frozen_string_literal: true

module LinkedRails
  class CurrentUser
    include ActiveModel::Model
    include LinkedRails::Model

    attr_accessor :user

    def actor_type
      if user.is_a?(LinkedRails.guest_user_class)
        'GuestUser'
      else
        'ConfirmedUser'
      end
    end

    def rdf_type
      Vocab.ontola[actor_type]
    end

    class << self
      def route_key
        :c_a
      end
    end
  end
end
