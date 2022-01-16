# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: 'json' } do
    resources :patients,    only: %i[index create update destroy]
    resources :vital_signs, only: %i[index create update]

    put '/patients/:id/activate',      to: 'patients#activate'
    put '/patients/:id/inactivate',    to: 'patients#inactivate'
  end
end
