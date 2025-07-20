require 'sidekiq/web'

Rails.application.routes.draw do
  # Devise custom paths
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    sign_up: 'signup'
  }, controllers: {
    registrations: 'registrations'
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

  # Email verification routes
  get "verification", to: "verification#index"
  post "verification/send", to: "verification#send_code", as: :send_verification_code
  post "verification/verify", to: "verification#verify", as: :verify
  post "verification/resend", to: "verification#resend_code", as: :resend_verification_code

  # Phone verification routes
  get "phone_verification", to: "phone_verification#new", as: :new_phone_verification
  post "phone_verification", to: "phone_verification#create"
  get "phone_verification/verify", to: "phone_verification#verify", as: :verify_phone
  post "phone_verification/confirm", to: "phone_verification#confirm", as: :confirm_phone
  post "phone_verification/resend", to: "phone_verification#resend", as: :resend_phone_verification

  # Twilio TwiML for voice verification
  post "twilio/twiml", to: "twilio#twiml", as: :twilio_twiml

  # Conversations & messages
  resources :conversations, only: [:index, :show, :create] do
    resources :messages, only: [:create]
  end
end
