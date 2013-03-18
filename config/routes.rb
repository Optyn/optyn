Optyn::Application.routes.draw do

  get "connections/index"

  root to: 'main#index'

  # Static Pages created by Alen
  match 'comingsoon' => 'main#comingsoon'
  match 'about' => 'main#about'
  match 'faq' => 'main#faq'
  match 'pricing' => 'main#pricing'
  match 'merchantfeatures' => 'main#merchantfeatures'
  match 'consumerfeatures' => 'main#consumerfeatures'
  match 'contact' => 'main#contact'
  match 'terms' => 'main#terms'
  match 'privacy' => 'main#privacy'
  match 'danacafe' => 'main#danacafe'

  # Blog Redirect
  match "/blog" => redirect("http://blog.optyn.com")

  #get '/upgrade' => 'subscriptions#upgrade'
  #post '/subscribe' => 'subscriptions#subscribe'
  #get '/edit_billing_info' => 'subscriptions#edit_billing_info'
  #put '/update_billing_info' => 'subscriptions#update_billing_info'
  
  devise_for :users, :path_names  => { :sign_out => 'logout',
    :sign_in  => 'login',
    :sign_up  => 'register' 
    },:controllers => {:registrations => 'users/registrations',:sessions => 'users/sessions', :passwords => 'users/passwords'}

    devise_scope :user do
    # Sessions
    post '/login'         => 'users/sessions#create',       :as => :user_session
    get  '/login'         => 'users/sessions#new',          :as => :new_user_session
    get  '/logout'        => 'devise/sessions#destroy',      :as => :destroy_user_session

    # Passwords
    post '/password'      => 'users/passwords#create',     :as => :user_password
    put  '/password'      => 'users/passwords#update'
    get  '/password/new'  => 'users/passwords#new',        :as => :new_user_password
    get  '/password/edit' => 'users/passwords#edit',       :as => :edit_user_password

    # Registrations
    post   '/register'    => 'users/registrations#create', :as => :user_registration
    get    '/register'    => 'users/registrations#new',    :as => :new_user_registration
    get    '/account'     => 'users/registrations#edit',   :as => :edit_user_registration
    put    '/account'     => 'users/registrations#update'
    delete '/account'     => 'users/registrations#destroy'
    get    '/zips/new'    => 'users/zips#new',             :as => :new_user_zip
    post   '/zips'        => 'users/zips#create',           :as => :user_zips  
  end

  match '/auth/:provider/callback', to: 'omniauth_clients#create'
  match '/auth/failure' => 'omniauth_clients#failure'
  match "/stripe_events", :to => "events#stripe_events", :as => :stripe_events, :via => :post

  resources :connections

  #Mount resque :)
mount Resque::Server, :at => "/resque"

namespace :api do
  scope module: :v1 do
    get 'shop/:app_id/details', to: 'shops#details',  as: :shop_details 
    get 'shop/button_framework.js', to: 'shops#button_framework'
    match 'user', to: 'users#show', as: :user_profile
  end
end

namespace "merchants" do |merchant|

  get "show_managers" => "merchant_managers#show_managers"

  devise_for :managers,:controllers=> {
    :registrations => 'merchants/managers/registrations', 
    :sessions => 'merchants/managers/sessions',
    :passwords => 'merchants/managers/passwords',
    :confirmations => 'merchants/managers/confirmations'
    } do 
      get '/add_manager' => 'managers/registrations#add_manager'
      post '/create_new_manager' => 'managers/registrations#create_new_manager'
    end

  resource :app 
  resources :connections
  resources :locations 
  resource :shop 
  resource :subscription
  get '/upgrade' => 'subscriptions#upgrade'
  post '/subscribe' => 'subscriptions#subscribe'
  get '/edit_billing_info' => 'subscriptions#edit_billing_info'
  put '/update_billing_info' => 'subscriptions#update_billing_info'
  
end

use_doorkeeper do
    controllers :authorizations => 'oauth_authorizations'
end


  #Link to the customer facing side static pages converted to layout with HAML
  namespace "front_end_static_page" do |front|
    resources :samples do
      collection do
        get 'aboutus'
        get 'blog'
        get 'blog_post'
        get 'coming_soon'
        get 'faq'
        get 'features'
        get 'portfolio'
        get 'pricing'
        get 'reset'
        get 'signin'
        get 'signup'
      end
    end
  end

  #Link to the admin side static pages converted to layout with HAML
  namespace "back_end_static_page" do |back|
    resources :samples do
      collection do
        get "calendar"
        get "chart"
        get "file_manager"
        get "form"
        get "gallery"
        get "icon"
        get "infrastructure"
        get "login"
        get "messages"
        get "submenu"
        get "table"
        get "tasks"
        get "typography"
        get "ui"
        get "widgets"
      end
    end
  end
end
