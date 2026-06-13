Rails.application.routes.draw do
  # auth routes
  get    "/signup", to: "users#new",        as: :signup
  post   "/signup", to: "users#create"
  get    "/login",  to: "sessions#new",     as: :login
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout

  # app routes
  resources :trips do
    resources :expenses, only: [ :new, :create, :edit, :update, :destroy ]
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"
end
