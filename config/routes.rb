Rails.application.routes.draw do
  # Root path (landing page)
  root "pages#landing"

  # Session routes (login/logout)
  get "/login", to: "sessions#new"
  post "/sessions", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  # Admin dashboard
  get "/admin", to: "posts#index"

  # Posts routes (standard CRUD)
  resources :posts

  # Categories routes (for managing categories)
  resources :categories, only: [ :index, :create, :destroy ]

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
