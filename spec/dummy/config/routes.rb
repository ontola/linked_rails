# frozen_string_literal: true

Rails.application.routes.draw do
  concern :nested_actionable do
    namespace :actions do
      resources :items, path: '', only: %i[index show], collection: @scope.parent.try(:[], :controller)
    end
  end

  resources :records do
    collection { concerns :nested_actionable }
  end
end
