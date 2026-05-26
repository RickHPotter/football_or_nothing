Rails.application.routes.draw do
  resource :registration, only: %i[ new create ]
  resource :session
  resources :careers, only: %i[new create show] do
    post :advance, on: :member
    post :rollover, on: :member
    resource :club, only: :show
    resource :training_plan, only: :update
    resources :athletes, only: :show
    resources :staff_contracts, only: %i[index create]
    resources :scouting_assignments, only: %i[index create]
    resources :youth_intakes, only: %i[index create] do
      post :promote, on: :collection
    end
    resources :transfers, only: %i[index create] do
      post :complete_offer, on: :member
    end
    resources :fixtures, only: :show do
      post :simulate, on: :member
      post :start, on: :member
      post :pause, on: :member
      post :resume, on: :member
      post :start_matchday, on: :member
      patch :pause_matchday, on: :member
      patch :resume_matchday, on: :member
      patch :focus_matchday, on: :member
      post :advance_clock, on: :member
      patch :tactics, on: :member
      post :regenerate_lineup, on: :member
      patch :swap_lineup_athletes, on: :member
      patch :update_lineup_role, on: :member
      post :substitute, on: :member
    end
    resources :manager_contracts, only: :create
    resources :countries, only: %i[index show]
    resources :clubs, only: %i[index show], as: :browse_clubs
    resources :tournaments, only: %i[index show]
  end
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
