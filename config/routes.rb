Optyn::Application.routes.draw do

  #Admin
  devise_for :admins, :controllers => {:sessions => 'admin/sessions', :passwords => 'admin/passwords'}
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  root to: 'main#index'
  match 'dashboard' => 'dashboards#index', as: :consumers_root
  match 'merchants' => 'merchants/dashboards#index', as: :merchants_root

  match 'index_backup' => 'main#index_backup'

  # Static Pages created by Alen. Please make sure if the static pages are modified the ssl enforcement is changed too.
  match 'about' => 'main#about', :as => :about
  match 'faq' => 'main#faq', :as => :faq
  match 'pricing' => 'main#pricing', :as => :pricing
  match 'merchant-features' => 'main#merchantfeatures', :as => :merchant_features
  match 'consumer-features' => 'main#consumerfeatures', :as => :consumer_features
  match 'contact' => 'main#contact', :as => :contact
  match 'terms' => 'main#terms', :as => :terms
  match 'privacy' => 'main#privacy', :as => :privacy
  match 'danacafe' => 'main#danacafe'
  match 'thankyou' => 'main#thankyou'
  match 'old_index' => 'main#old_index'
  match 'cache/flush' => "cache#flush"
  match '/shop/public/:identifier', to: 'shops#show'

  # Blog Redirect
  match "/blog" => redirect("http://optynblog.com"), :as => :blog

  # Biz Redirect
  match "/biz" => 'main#merchantfeatures'    

  # Zendesk Support Desk Redirect
  match "/support" => redirect("http://support.optyn.com"), :as => :support

  match '/email/logger/:token', to: 'email_read_logger#info', as: :email_read_logger


  devise_for :users, :path_names => {:sign_out => 'logout',
                                     :sign_in => 'login',
                                     :sign_up => 'register'
  }, :controllers => {:registrations => 'users/registrations', :sessions => 'users/sessions', :passwords => 'users/passwords'} do
    get "/users/sessions/cross_domain_app_login" => "sessions#cross_domain_app_login", :as => :cross_domain_app_login
  end

  devise_scope :user do
    # Sessions
    post '/login' => 'users/sessions#create', :as => :user_session
    post '/api/login', to: 'users/sessions#create'
    get '/login' => 'users/sessions#new', :as => :new_user_session
    get '/logout' => 'devise/sessions#destroy', :as => :destroy_user_session

    # Passwords
    post '/password' => 'users/passwords#create', :as => :user_password
    put '/password' => 'users/passwords#update'
    get '/password/new' => 'users/passwords#new', :as => :new_user_password
    get '/password/edit' => 'users/passwords#edit', :as => :edit_user_password

    # Registrations
    post '/register' => 'users/registrations#create', :as => :user_registration
    post '/api/register', to: 'users/registrations#create'
    get '/register' => 'users/registrations#new', :as => :new_user_registration
    get '/api/register', to: 'users/registrations#new'
    get '/account' => 'users/registrations#edit', :as => :edit_user_registration
    put '/account' => 'users/registrations#update'
    delete '/account' => 'users/registrations#destroy'
    get '/profile' => 'users/registrations#profile'
    put '/profile' => 'users/registrations#update_profile'
    match '/authenticate_with_email' => 'users/sessions#authenticate_with_email', :as => :authenticate_with_email
  end

  match '/auth/:provider/callback', to: 'omniauth_clients#create'
  match '/auth/failure' => 'omniauth_clients#failure'
  match '/omniauth_clients/login_type', to: 'omniauth_clients#login_type', as: :login_type_omniauth_clients
  post 'omniauth_clients/create_for_twitter', to: 'omniauth_clients#create_for_twitter', as: :create_for_twitter_omniauth_clients

  match "/stripe_events", :to => "events#stripe_events", :as => :stripe_events, :via => :post

  resources :connections do
    collection do
      post 'add_connection'
      get 'make'
      get 'dropped'
    end

    member do
      get 'shop'
      put 'disconnect', as: :disconnect
      post 'connect', as: :connect
      get 'removal_confirmation'
      put 'opt_out'
    end
  end

  resources :segments do
    member do
      post :save_answers
      get :default
    end
  end

  match '/messages', to: 'messages#inbox'
  resources :messages, except: [:index, :new, :create, :edit, :update, :destroy] do
    collection do
      get :inbox
      get :saved
      get :trash
      put :move_to_trash
      put :move_to_saved
      put :move_to_inbox
      put :discard
    end
  end

  #Mount resque :)
  mount Resque::Server, :at => "/resque"

  namespace :api do
    scope module: :v1 do
      get 'shop/:app_id/details', to: 'shops#details', as: :shop_details
      get 'shop/button_script.js', to: 'shops#button_script'
      get 'shop/button_framework.js', to: 'shops#button_framework'
      post 'shop', to: 'shops#create'
      match 'user', to: 'users#show', as: :user_profile
      get 'user/check_connection.json', to: 'users#check_connection'
      post 'user/create_connection.json', to: 'users#create_connection'
      get 'user/create_error', to: 'users#create_error'
      get 'user/alias', to: 'users#alias'
      get '/login', to: 'optyn_button#login', as: :login
      get '/connection', to: 'optyn_button#connection', as: :connection
      put '/automatic_connection', to: 'optyn_button#automatic_connection', as: :automatic_connection
      put '/update_permissions', to: 'optyn_button#update_permissions', as: :update_permissions
      put '/connect_with_email', to: 'optyn_button#connect_via_email'

      namespace :merchants do
        post 'messages/create_virtual', to: 'virtual_messages#create_virtual', as: :create_virtual
      end
    end
  end

  namespace "merchants" do |merchant|

    devise_for :managers, :controllers => {
        :registrations => 'merchants/managers/registrations',
        :sessions => 'merchants/managers/sessions',
        :passwords => 'merchants/managers/passwords',
        :confirmations => 'merchants/managers/confirmations'
    }

    devise_scope :managers do
      get "show_managers" => "merchant_managers#show_managers", as: :managers_list
      get '/add_manager' => 'merchant_managers#add_manager'
      post '/create_new_manager' => 'merchant_managers#create_new_manager'
    end

    resource :app
    resources :connections
    resources :locations
    resources :dashboards
    resources :file_imports
    resource :shop do
      member do
        get :check_identifier
      end
    end

    
    resource :subscription
    get '/upgrade' => 'subscriptions#upgrade', as: :upgrade_subscription
    put '/subscribe' => 'subscriptions#subscribe', as: :subscribe
    get '/edit_billing_info' => 'subscriptions#edit_billing_info'
    put '/update_billing_info' => 'subscriptions#update_billing_info'

    resource :survey, only: [:show, :edit, :update], path: :segment do
      member do
        get 'questions'
        get 'preview'
        get 'launch'
      end

      resources :survey_questions, only: [:new, :edit, :create, :update, :destroy], path: "segment_questions"

      resources :survey_answers, path: "answers" do
        collection do
          post 'create_label'
          post 'update_labels'
        end
      end
    end

    resources :labels, except: [:show]

    get "messages/new/:message_type" => 'messages#new', as: 'new_campaign'
    get "messages/" => "messages#types", as: 'campaign_types'
    resources :messages do
      collection do
        get :types
        get :drafts
        get :trash
        get :sent
        get :queued
        put :move_to_trash
        put :move_to_draft
        put :discard
      end

      member do
        get :preview
        get :launch
        put :update_meta
        put :create_response_message
        delete :discard_response_message
        get :report
        put :update_header
      end
    end
  end

  match 'oauth/token', to: "oauth_tokens#create"
  use_doorkeeper do
    controllers :authorizations => 'oauth_authorizations'
    controllers :tokens => 'oauth_tokens'
  end

  # match '/:identifier' => 'shops#show', :as => :shop
end
