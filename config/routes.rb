Rails.application.routes.draw do
  get "messages/create"
  get "conversations/index"
  get "conversations/show"
  get "conversations/create"

  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    sign_up: 'signup'
  }

  post "/chat/summarize_memory", to: "chat#summarize_memory", as: :summarize_memory

  root to: 'chat#new'
  get "chat", to: "chat#new"
  post "chat", to: "chat#create"
  post '/chat/stream', to: 'chat#stream'

  get "profiles/edit", to: "profiles#edit", as: :profiles_edit
  get "profiles/update", to: "profiles#update", as: :profiles_update

  get "up", to: "rails/health#show", as: :rails_health_check

  # ✅ Add this block for conversations + messages
  resources :conversations, only: [:index, :show, :create] do
    resources :messages, only: [:create]
  end
end
