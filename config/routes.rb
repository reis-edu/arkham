# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :visitors, defaults: { format: 'json' } do
    post '/login',    to: 'authentication#login'
    post '/new',      to: 'visitors#create'
    resources :visits
  end

  namespace :api, defaults: { format: 'json' } do
    resources :patients,    only: %i[index create update destroy]
    resources :vital_signs, only: %i[index create update]

    put '/patients/:id/activate',      to: 'patients#activate'
    put '/patients/:id/inactivate',    to: 'patients#inactivate'
  end
end
