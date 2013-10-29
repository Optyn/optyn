Optyn::Application.routes.draw do

  #Admin
  devise_for :admins, :controllers => {:sessions => 'admin/sessions', :passwords => 'admin/passwords'}
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  root to: 'main#index'
  match 'dashboard' => 'dashboards#index', as: :consumers_root
  match 'merchants' => 'merchants/dashboards#index', as: :merchants_root

  match 'index_backup_2_columns' => 'main#index_backup_2_columns'

  # Static Pages created by Alen. Please make sure if the static pages are modified the ssl enforcement is changed too.
  match 'about' => 'main#about', :as => :about
  match 'faq' => 'main#faq', :as => :faq
  match 'pricing' => 'main#pricing', :as => :pricing
  match 'features' => 'main#merchantfeatures', :as => :merchant_features
  match 'consumer-features' => 'main#consumerfeatures', :as => :consumer_features
  match 'contact' => 'main#contact', :as => :contact
  match 'terms' => 'main#terms', :as => :terms
  match 'privacy' => 'main#privacy', :as => :privacy
  match 'danacafe' => 'main#danacafe'
  match 'thankyou' => 'main#thankyou'
  match 'old_index' => 'main#old_index'
  match 'cache/flush' => "cache#flush"
  match '/shop/public/:identifier' =>"shops#show", :as => :public_shop
  match '/shop/subscribe_with_email' => 'shops#subscribe_with_email', :as=>:subscribe_with_email
  # Static pages created by Aniket.
  match 'tour' => 'main#tour'
  match 'partner_with_us' => 'main#partner_with_us'
  match 'testimonials/alley-gallery' => 'main#testimonial_alley_gallery'


  # Blog Redirect
  match "/blog" => redirect("http://blog.optyn.com"), :as => :blog

  # Biz Redirect
  match "/biz" => 'main#merchantfeatures'
  match "/merchant-features" => 'main#merchantfeatures'  

  # Zendesk Support Desk Redirect
  match "/support" => redirect("http://optyn.uservoice.com"), :as => :support

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

  namespace :api  do
    scope module: :v1 do
      get '/me', to: 'credentials#me', as: :shop_details
      get 'shop/:app_id/details', to: 'shops#details', as: :shop_details
      get 'shop/button_script.js', to: 'shops#button_script'
      get 'shop/button_framework.js', to: 'shops#button_framework'

      post 'shop', to: 'shops#create'
      get 'shop', to: 'shops#all'

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
        resources :shops do
          collection do
            get :import_list
            get :import_user_list
            post :import_user
            post :import
            get :import_status
            get :active_connections
          end

        end

        resources :managers do
          collection do
            get :get_manager_from_email
            post :logout_manager
          end
        end
        
        resources :locations
        resources :messages do
          collection do
            get :types
            get :drafts
            get :queued
            get :sent
            get :trash
            put :move_to_trash
            put :move_to_draft
            put :discard
            get :folder_counts
          end

          member do
            put :launch
            get :preview
            put :update_meta
          end
        end #end of messages resource

        resources :users do
          collection do
            post :import
            get :import_list
            get :import_status
          end
        end #end of consumers resources   
      end #end of the merchants namespace

      namespace :partners do
        get 'login', to: 'login#new'
        post 'login', to: 'login#create'
      end #end of the partners namespace
    end #end of the scope v1
  end #end of the api namespace

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
    resources :connections do
      collection do
        match 'unsubscribe/:id', to: "connections#unsubscribe_user", as: :unsubscribe
        match 'update_user/:id', to: "connections#update_user", as: :update_user
        match 'add_user', to: "connections#add_user", as: :add_user
        match 'create_user', to: "connections#create_user", as: :create_user
        match 'edit_user/:id', to: "connections#edit", as: :edit_user
        match 'search', to: "connections#search", as: :search
        post 'create_label'
        post 'update_labels'
        post 'create_labels_for_user'
      end
    end
    resources :locations
    resources :social_profiles
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

  namespace :reseller do
    devise_for :partners, :controllers => {
        :registrations => 'reseller/partners/registrations',
        :sessions => 'reseller/partners/sessions',
        :passwords => 'reseller/partners/passwords',
        :confirmations => 'reseller/partners/confirmations'
    }

    # devise_scope :partner do
    #   get '/api/partners/login', to: 'partners/sessions#new'
    # end

    get '/resellerjs' => 'dashboards#resellerjs'
  end
end
