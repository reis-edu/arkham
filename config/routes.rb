Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :visitors, defaults: { format: 'json' } do
    post '/login',                to: 'authentication#login'
    post '/new',                  to: 'visitors#create'
    
    resources :visits
    get '/patients',              to: 'visits#patients'
  end

  namespace :api, defaults: { format: 'json' } do
    get '/patients/presigned-profile-url',  to: 'patients#presigned_profile_url'

    resources :patients,    only: %i[index show create update destroy]

    put '/patients/:id/activate',           to: 'patients#activate'
    put '/patients/:id/inactivate',         to: 'patients#inactivate'
  end
end
