# frozen_string_literal: true

class RecordPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      user.try(:[], :admin) ? scope : scope.where(admin: false)
    end
  end

  permit_attributes %i[title body]
end
