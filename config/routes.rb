Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :visitors, defaults: { format: 'json' } do
    post '/login',                to: 'authentication#login'
    post '/new',                  to: 'visitors#create'
    
    resources :visits
    get '/patients',              to: 'visits#patients'
  end

  namespace :api, defaults: { format: 'json' } do
    resources :patients,    only: %i[index create update destroy]

    put '/patients/:id/activate',      to: 'patients#activate'
    put '/patients/:id/inactivate',    to: 'patients#inactivate'
  end
end
