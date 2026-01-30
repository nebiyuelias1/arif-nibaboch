Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "/telegram_mini_app/login", to: "telegram_mini_app_login#create"


  get "/telegram_login/callback", to: "telegram_login#callback", as: :telegram_login_callback


  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "books#index"

  # Book resources (public)
  resources :books do
    resources :ratings, only: [ :create ]
  end

  # Simple API namespace for small JSON endpoints
  namespace :api do
    namespace :v1 do
      # GET /api/v1/auth/check - returns JSON about current authentication state
      get "auth/check", to: "auth#check"
    end
  end

  authenticate :user do
    resources :users, only: [ :index, :show ]
    get "profile", to: "users#show", as: :profile
  end
end
