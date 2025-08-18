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

  # ✅ PagesController routes (static & informational pages)
  get "features",          to: "pages#features"
  get "login",             to: "pages#login"
  get "signup",            to: "pages#signup"
  get "pricing",           to: "pages#pricing"
  get "api-documentation", to: "pages#api_docs"
  get "blog",              to: "pages#blog"

  get "help-center",       to: "pages#help_center"
  get "community-forum",   to: "pages#forum"
  get "contact-us",        to: "pages#contact"
  get "feedback",          to: "pages#feedback"
  get "system-status",     to: "pages#status"

  get "about-us",          to: "pages#about"
  get "careers",           to: "pages#careers"
  get "partners",          to: "pages#partners"
  get "press-kit",         to: "pages#press"
  get "newsroom",          to: "pages#news"

  get "privacy-policy",    to: "pages#privacy"
  get "terms-of-service",  to: "pages#terms"
  get "cookie-policy",     to: "pages#cookies"
  get "data-processing",   to: "pages#data_processing"
  get "compliance",        to: "pages#compliance"
  get "disclaimer",        to: "pages#disclaimer"

  get "sitemap",           to: "pages#sitemap"
  get "accessibility",     to: "pages#accessibility"
  get "ethics",            to: "pages#ethics"

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
  get  "verification",        to: "verification#index"
  post "verification/send",   to: "verification#send_code",     as: :send_verification_code
  post "verification/verify", to: "verification#verify",        as: :verify_email_code
  post "verification/resend", to: "verification#resend_code",   as: :resend_verification_code

  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: redirect('/')
  get '/signout', to: 'sessions#destroy', as: 'signout'
  delete '/logout', to: 'sessions#destroy'

  # Phone verification routes
  get  "phone_verification",        to: "phone_verification#new",     as: :new_phone_verification
  post "phone_verification",        to: "phone_verification#create"
  get  "phone_verification/verify", to: "phone_verification#verify",  as: :verify_phone
  post "phone_verification/confirm",to: "phone_verification#confirm", as: :confirm_phone
  post "phone_verification/resend", to: "phone_verification#resend",  as: :resend_phone_verification

  # Twilio TwiML for voice verification
  post "twilio/twiml", to: "twilio#twiml", as: :twilio_twiml

  # Conversations & messages (web)
  resources :conversations, only: [:index, :show, :create] do
    resources :messages, only: [:create]
  end

  # Add API namespace for JSON endpoints
  namespace :api, defaults: { format: :json } do
    resources :conversations, only: [:index, :show, :create] do
      resources :messages, only: [:index, :create]
    end
  end
end
