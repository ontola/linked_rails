# frozen_string_literal: true

class RecordPolicy < ApplicationPolicy
  def permitted_attributes
    %i[title body]
  end
end
