# frozen_string_literal: true

class ApplicationPolicy
  include LinkedRails::Policy

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  attr_reader :record

  def initialize(user_context, record)
    @user_context = user_context
    @record = record
  end
end
