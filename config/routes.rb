require 'sidekiq/web'

Rails.application.routes.draw do
  # Devise custom paths
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    sign_up: 'signup'
  }

  # 👇 Always land on login page by default
  unauthenticated do
    root to: redirect('/login')
  end

  authenticated :user do
    root to: 'chat#new', as: :authenticated_root
  end

  # Health check
  if Rails.env.development?
    get "/.well-known/*path", to: ->(env) { [204, {}, []] }
  end
  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?

  # Chat routes
  get "chat", to: "chat#new"
  post "chat", to: "chat#create"
  post "/chat/stream", to: "chat#stream"
  post "/chat/summarize_memory", to: "chat#summarize_memory", as: :summarize_memory
  get "/ping_test", to: "chat#ping_test"
  # Profile routes
   get "profiles/edit", to: "profiles#edit", as: :profiles_edit
   get "profiles/update", to: "profiles#update", as: :profiles_update

  # Rails health check
  get "up", to: "rails/health#show", as: :rails_health_check

  # Conversations & messages
  resources :conversations, only: [:index, :show, :create] do
    resources :messages, only: [:create]
  end
end
