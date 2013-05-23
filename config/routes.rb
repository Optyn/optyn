Optyn::Application.routes.draw do

  #Admin
  devise_for :admins, :controllers => {:sessions => 'admin/sessions', :passwords => 'admin/passwords'}
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  root to: 'main#index'
  match 'connections' => 'connections#index', as: :customers_root
  match 'merchants' => 'merchants/dashboard#index', as: :merchants_root
  match 'dashboard' => 'dashboards#index', as: :consumer_dashboard


  # Static Pages created by Alen
  match 'comingsoon' => 'main#comingsoon'
  match 'about' => 'main#about', :as => :about
  match 'faq' => 'main#faq', :as => :faq
  match 'pricing' => 'main#pricing', :as => :pricing
  match 'merchantfeatures' => 'main#merchantfeatures', :as => :merchant_features
  match 'consumerfeatures' => 'main#consumerfeatures', :as => :consumer_features
  match 'contact' => 'main#contact', :as => :contact
  match 'terms' => 'main#terms', :as => :terms
  match 'privacy' => 'main#privacy', :as => :privacy
  match 'danacafe' => 'main#danacafe'
  match 'thankyou' => 'main#thankyou'
  match 'old_index' => 'main#old_index'
  match 'cache/flush' => "cache#flush"

  # Blog Redirect
  match "/blog" => redirect("http://blog.optyn.com"), :as => :blog

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
    get '/login' => 'users/sessions#new', :as => :new_user_session
    get '/logout' => 'devise/sessions#destroy', :as => :destroy_user_session

    # Passwords
    post '/password' => 'users/passwords#create', :as => :user_password
    put '/password' => 'users/passwords#update'
    get '/password/new' => 'users/passwords#new', :as => :new_user_password
    get '/password/edit' => 'users/passwords#edit', :as => :edit_user_password

    # Registrations
    post '/register' => 'users/registrations#create', :as => :user_registration
    get '/register' => 'users/registrations#new', :as => :new_user_registration
    get '/account' => 'users/registrations#edit', :as => :edit_user_registration
    put '/account' => 'users/registrations#update'
    delete '/account' => 'users/registrations#destroy'
    get '/zips/new' => 'users/zips#new', :as => :new_user_zip
    post '/zips' => 'users/zips#create', :as => :user_zips
    get '/profile' => 'users/registrations#profile'
    put '/profile' => 'users/registrations#update_profile'

  end

  match '/auth/:provider/callback', to: 'omniauth_clients#create'
  match '/auth/failure' => 'omniauth_clients#failure'
  match '/omniauth_clients/login_type', to: 'omniauth_clients#login_type', as: :login_type_omniauth_clients

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
      post 'connect',   as: :connect
    end
  end

  resources :segments do
    member do
      post :save_answers
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
      get 'shop/button_framework.js', to: 'shops#button_framework'
      match 'user', to: 'users#show', as: :user_profile
      get '/login', to: 'oauth#login', as: :login
      get '/connection', to: 'oauth#connection', as: :connection
      put '/update_permissions', to: 'oauth#update_permissions', as: :update_permissions
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
    get '/upgrade' => 'subscriptions#upgrade'
    post '/subscribe' => 'subscriptions#subscribe', as: :subscribe
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
      end
    end
  end

  use_doorkeeper do
    controllers :authorizations => 'oauth_authorizations'
  end
end
