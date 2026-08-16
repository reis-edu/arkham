# frozen_string_literal: true

Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check

  get 'monitoring' => 'monitoring#show', defaults: { format: 'json' }

  namespace :visitors, defaults: { format: 'json' } do
    post '/login',                to: 'authentication#login'
    post '/new',                  to: 'visitors#create'

    resources :visits
    get '/patients', to: 'visits#patients'
  end

  namespace :api, defaults: { format: 'json' } do
    get '/patients/presigned-profile-url', to: 'patients#presigned_profile_url'

    resources :patients, only: %i[index show create update destroy]

    put '/patients/:id/activate',           to: 'patients#activate'
    put '/patients/:id/inactivate',         to: 'patients#inactivate'

    post '/auth/login',                     to: 'authentication#login'
    post '/auth/refresh',                   to: 'authentication#refresh'

    resources :users, only: %i[index create destroy]

    put '/users/:id/password',              to: 'users#change_password'
    put '/users/:id/group',                 to: 'users#change_group'
    put '/users/:id/inactivate',            to: 'users#inactivate'

    resources :shift_items, only: %i[index show create update destroy]

    get  '/shifts/current',                 to: 'shifts#current'
    post '/shifts/copy_last',               to: 'shifts#copy_last'
    resources :shifts, only: %i[index show create update destroy]
    put  '/shifts/:id/finalize_execution',  to: 'shifts#finalize_execution'
    put  '/shifts/:id/finalize_review',     to: 'shifts#finalize_review'
    get  '/shifts/:id/divergences',         to: 'shifts#divergences'

    post   '/shifts/:shift_id/items',                       to: 'shifts#add_item'
    delete '/shifts/:shift_id/items/:shift_item_id',        to: 'shifts#remove_item'

    put  '/shifts/:shift_id/items/:shift_item_id/check',  to: 'shift_item_checks#check'
    put  '/shifts/:shift_id/items/:shift_item_id/review', to: 'shift_item_checks#review'
  end
end
