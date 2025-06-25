Rails.application.routes.draw do
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    sign_up: 'signup'
  }

  root to: 'chat#new'  # homepage
  get "chat", to: "chat#new"  # Allow visiting /chat
  post "chat", to: "chat#create"  # Form submits here

  get "profiles/edit", to: "profiles#edit", as: :profiles_edit
  get "profiles/update", to: "profiles#update", as: :profiles_update

  get "up", to: "rails/health#show", as: :rails_health_check
end
