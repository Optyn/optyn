Optyn::Application.routes.draw do

  #Admin
  devise_for :admins, :controllers => {:sessions => 'admin/sessions', :passwords => 'admin/passwords'}
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'


  root to: 'main#index'
  get 'robots.:format', to: 'main#robots'
  match 'dashboard' => 'dashboards#index', as: :consumers_root
  match 'merchants' => 'merchants/dashboards#index', as: :merchants_root
  match '/video-tutorials' => 'main#merchant_video_tutorials', :as => :video_tutorials
  match '/case-studies/bandung-restaurant' => 'main#bandung_case_study', :as => :bandung_case_study
  match '/case-studies/salvatores-restaurant' => 'main#salvatores_case_study', :as => :salvatores_case_study
  match '/constant-contact-offer' => 'main#constant_contact', :as => :constant_contact
  match '/mailchimp-offer' => 'main#mailchimp_offer', :as => :mailchimp
  match '/aweber-offer' => 'main#aweber_offer', :as => :aweber

  # Static Pages created by Alen. Please make sure if the static pages are modified the ssl enforcement is changed too.
  match 'about' => 'main#about', :as => :about
  match 'faq' => 'main#faq', :as => :faq
  match 'pricing' => 'main#pricing', :as => :pricing
  match 'features' => 'main#merchantfeatures', :as => :merchant_features
  match 'consumer-features' => 'main#consumerfeatures', :as => :consumer_features
  match 'contact' => 'main#contact', :as => :contact
  match 'terms' => 'main#terms', :as => :terms
  match 'anti-spam-policy' => 'main#anti_spam_policy', :as => :anti_spam_policy
  match 'privacy' => 'main#privacy', :as => :privacy
  match 'danacafe' => 'main#danacafe'
  match 'thankyou' => 'main#thankyou'
  match 'old_index' => 'main#old_index'
  match 'cache/flush' => "cache#flush"
  match '/shop/public/:identifier' =>"shops#show", :as => :public_shop
  match '/shop/subscribe_with_email' => 'shops#subscribe_with_email', :as=>:subscribe_with_email
  match 'tour' => 'main#tour', :as => :tour_page
  match 'affiliates' => 'main#affiliates'
  match 'product_announcement' => 'main#product_announcement'
  # match 'testimonials' => 'main#testimonials'
  match '/:shop/campaigns/:message_name' => 'merchants/messages#public_view', :as => :public_view_messages
  match 'testimonials/alley-gallery' => 'main#testimonial_alley_gallery', :as => :alley_gallery_testimonial
  match 'sitemap' => 'main#sitemap', :as => :website_sitemap
  match 'sitemap-customer-profiles' => 'main#sitemap_customer_profiles', :as => :profile_sitemap

  #sell pages under marketing
  match '/marketing' => 'main#marketing', :as => :marketing
  match '/marketing/email-marketing' => 'main#email_marketing', :as => :email_marketing
  match '/marketing/social-media-marketing' => 'main#social_media', :as => :social_media_marketing 
  match '/marketing/marketing-automation' => 'main#marketing_automation', :as => :marketing_automation
  match '/marketing/marketing-syndication' => 'main#marketing_syndication', :as => :marketing_syndication
  match '/marketing/surveys' => 'main#surveys', :as => :surveys
  match '/marketing/coupons' => 'main#coupons', :as => :coupons
  match '/marketing/specials-and-sales' => 'main#specials', :as => :specials
  match '/marketing/contests' => 'main#contests', :as => :contests
  match '/marketing/marketing-ideas' => 'main#marketing_recommendation', :as => :marketing_ideas
  match '/marketing/loyalty-marketing' => 'main#loyalty_marketing', :as => :loyalty_marketing
  match '/marketing/customer-retention' => 'main#customer_retention', :as => :customer_retention
  match '/marketing/marketing-analytics' => 'main#marketing_analytics', :as => :marketing_analytics
  match '/marketing/marketing-promotions' => 'main#marketing_promotions', :as => :marketing_promotions 
  match '/marketing/digital-marketing' => 'main#digital_marketing', :as => :digital_marketing
  match '/marketing/marketing-collaboration' => 'main#marketing_collaboration', :as => :marketing_collaboration
  match '/marketing/online-marketing' => 'main#online_marketing', :as => :online_marketing
  match '/marketing/automated-marketing' => 'main#automated_marketing', :as => :automated_marketing
  match '/marketing/multi-channel-marketing' => 'main#multi_channel_marketing', :as => :multi_channel_marketing
  match '/marketing/integrated-marketing' => 'main#integrated_marketing', :as => :integrated_marketing
  #subcategories for email marketing content
  match '/marketing/email-marketing/mobile-responsive-emails' => 'main#mobile_responsive', :as => :mobile_responsive
  match '/marketing/email-marketing/capturing-customer-emails' => 'main#capturing_data', :as => :capturing_data
  match '/marketing/email-marketing/email-deliverability' => 'main#email_deliverability', :as => :email_deliverability
  #additional pages that are keyword focused
  match '/marketing/free-email-marketing' => 'main#free_email_marketing', :as => :free_email_marketing
  match '/marketing/free-email-marketing-software' => 'main#free_email_marketing_software', :as => :free_email_marketing_software
  match '/marketing/free-newsletter-software' => 'main#free_newsletter_software', :as => :free_newsletter_software
  match '/marketing/mass-mail-software' => 'main#mass_mail_software', :as => :mass_mail_software
  match '/marketing/email-marketing-programs' => 'main#email_marketing_programs', :as => :email_marketing_programs
  match '/marketing/email-marketing-solutions' => 'main#email_marketing_solutions', :as => :email_marketing_solutions
  match '/marketing/email-blast-software' => 'main#email_blast_software', :as => :email_blast_software
  match '/marketing/bulk-email-software' => 'main#bulk_email_software', :as => :bulk_email_software
  match '/marketing/newsletter-software' => 'main#newsletter_software', :as => :newsletter_software
  match '/marketing/email-marketing-agency' => 'main#email_marketing_agency', :as => :email_marketing_agency
  match '/marketing/email-marketing-software' => 'main#email_marketing_software', :as => :email_marketing_software
  #resources pages for content pages
  match '/resources' => 'main#resources', :as => :resources
  match '/resources/email-marketing' => 'main#resources_email_marketing', :as => :resources_email_marketing
  match '/resources/email-marketing/capturing-customer-emails' => 'main#resources_capturing_customer_emails', :as => :resources_capturing_customer_emails
  match '/resources/email-marketing/capturing-customer-data' => 'main#resources_capturing_customer_data', :as => :resources_capturing_customer_data
  match '/resources/email-marketing/mobile-responsive-emails' => 'main#resources_mobile_responsive_emails', :as => :resources_mobile_responsive_emails
  match '/resources/email-marketing/evolution-of-email-marketing' => 'main#resources_evolution_email', :as => :resources_evolution_email
  match '/resources/email-marketing/email-marketing-best-practices' => 'main#resources_best_practices', :as => :resources_best_practices
  match '/resources/email-marketing/email-marketing-measuring-success' => 'main#resources_measuring_success', :as => :resources_measuring_success
  match '/resources/email-marketing/email-marketing-getting-started' => 'main#resources_email_marketing_getting_started', :as => :resources_getting_started
  match '/resources/email-marketing/email-marketing-email-types' => 'main#resources_email_marketing_types', :as => :resources_email_marketing_types
  match '/resources/email-marketing/email-marketing-tips' => 'main#resources_email_marketing_tips', :as => :resources_email_marketing_tips
  match '/resources/social-media-marketing' => 'main#resources_social_media', :as => :resources_social_media
  match '/resources/digital-marketing' => 'main#resources_digital_marketing', :as => :resources_digital_marketing
  match '/resources/contests' => 'main#resources_contests', :as => :resources_contests
  match '/resources/coupons' => 'main#resources_coupons', :as => :resources_coupons
  match '/resources/specials-and-sales' => 'main#resources_specials_sales', :as => :resources_specials_sales
  match '/resources/customer-retention' => 'main#resources_customer_retention', :as => :resources_customer_retention
  match '/resources/loyalty-marketing' => 'main#resources_loyalty_marketing', :as => :resources_loyalty_marketing
  match '/resources/surveys' => 'main#resources_surveys', :as => :resources_surveys
  match '/resources/marketing-analytics' => 'main#resources_marketing_analytics', :as => :resources_marketing_analytics
  match '/resources/online-marketing' => 'main#resources_online_marketing', :as => :resources_online_marketing
  match '/resources/marketing-automation' => 'main#resources_marketing_automation', :as => :resources_marketing_automation
  match '/resources/marketing-promotions' => 'main#resources_marketing_promotions', :as => :resources_marketing_promotions
  match '/resources/marketing-syndication' => 'main#resources_marketing_syndication', :as => :resources_marketing_syndication
  match '/resources/marketing-ideas' => 'main#resources_marketing_ideas', :as => :resources_marketing_ideas
  match '/resources/integrated-marketing' => 'main#resources_integrated_marketing', :as => :resources_integrated_marketing
  match '/resources/reachable-audience' => 'main#resources_reachable_audience', :as => :resources_reachable_audience
  #resources keyword specific pages
  match '/resources/email-marketing-system' => 'main#resources_email_marketing_system', :as => :resources_email_marketing_system
  match '/resources/cheap-email-marketing' => 'main#resources_cheap_email_marketing', :as => :resources_cheap_email_marketing
  match '/resources/best-bulk-email-software' => 'main#resources_best_bulk_email_software', :as => :resources_best_bulk_email_software
  match '/resources/top-email-marketing-software' => 'main#resources_top_email_marketing_software', :as => :resources_top_email_marketing_software
  match '/resources/email-broadcast' => 'main#resources_email_broadcast', :as => :resources_email_broadcast
  match '/resources/best-email-marketing' => 'main#resources_best_email_marketing', :as => :resources_best_email_marketing
  match '/resources/best-email-marketing-software' => 'main#resources_best_email_marketing_software', :as => :resources_best_email_marketing_software
  match '/resources/best-newsletter-software' => 'main#resources_best_newsletter_software', :as => :resources_best_newsletter_software
  match '/resources/bulk-email' => 'main#resources_bulk_email', :as => :resources_bulk_email
  match '/resources/direct-email-marketing' => 'main#resources_direct_email_marketing', :as => :resources_direct_email_marketing
  match '/resources/email-blast' => 'main#resources_email_blast', :as => :resources_email_blast
  match '/resources/best-free-email-marketing' => 'main#resources_best_free_email_marketing', :as => :resources_best_free_email_marketing
  match '/resources/email-advertising' => 'main#resources_email_advertising', :as => :resources_email_advertising
  match '/resources/email-campaign' => 'main#resources_email_campaign', :as => :resources_email_campaign
  match '/resources/email-templates' => 'main#resources_email_templates', :as => :resources_email_templates
  match '/resources/email-marketing-stats' => 'main#resources_email_marketing_stats', :as => :resources_email_marketing_stats
  match '/resources/small-business-email-marketing' => 'main#resources_small_business_email_marketing', :as => :resources_small_business_email_marketing
  match '/resources/email-marketing-strategy' => 'main#resources_email_marketing_strategy', :as => :resources_email_marketing_strategy
  match '/resources/how-to-email-marketing' => 'main#resources_how_to_email_marketing', :as => :resources_how_to_email_marketing
  match '/resources/catchy-email-subject-lines' => 'main#resources_catchy_email_subject_lines', :as => :resources_catchy_email_subject_lines
  match '/resources/top-email-marketing' => 'main#resources_top_email_marketing', :as => :resources_top_email_marketing
  match '/resources/email-marketing-online' => 'main#resources_email_marketing_online', :as => :resources_email_marketing_online
  match '/resources/what-is-email-marketing' => 'main#resources_what_is_email_marketing', :as => :resources_what_is_email_marketing
  match '/resources/follow-up-emails' => 'main#resources_follow_up_emails', :as => :resources_follow_up_emails
  match '/resources/email-types' => 'main#resources_email_types', :as => :resources_email_types
  match '/resources/email-newsletter' => 'main#resources_email_newsletter', :as => :resources_email_newsletter
  match '/resources/mass-email' => 'main#resources_mass_email', :as => :resources_mass_email
  match '/resources/opt-in-email-marketing' => 'main#resources_opt_in_email_marketing', :as => :resources_opt_in_email_marketing
  

  #share routes and QR Code
  match 'g/:message_id' => 'merchants/messages#generate_qr_code', :as => :generate_qr_code
  match 'redeem/:message_user' => 'merchants/messages#redeem'
  match '/share_on_facebook/:message_id' => 'merchants/facebook#index', :as => :share_on_facebook
  match '/share_message/:message_id' => 'merchants/facebook#share_message', :as => :share_message_facebook
  match 'share_email/:message_id' => 'merchants/messages#share_email', :as => :share_email
  match 'send_shared_email/:message_id' => 'merchants/messages#send_shared_email', :as => :send_shared_email

  #named routes partner inquiry
  get "/partner-with-us", to: 'partner_inquiries#new', as: :new_partner_inquiry
  post "/partner-with-us", to: 'partner_inquiries#create', as: :partner_inquiries
  
  #named routes partner inquiry
  get "/marketing-agency", to: 'marketing_agencies#new', as: :new_marketing_agencies
  post "/marketing-agency", to: 'marketing_agencies#create', as: :marketing_agencies
  match 'marketing-agency/thank-you' => "marketing_agencies#thank_you", :as => "marketing_agencies_thank_you"


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
      get :offer_relevant
    end    
  end

  #Mount Sidekiq Web :)
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
    [user, password] == ["", "9p5yn123"]
  end

  mount Ckeditor::Engine => "/ckeditor"
  

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
            get :credits
          end
        end

        resources :managers do
          collection do
            get :get_manager_from_email
            post :logout_manager
          end
        end

        resources :message_actions do
          member do
            get :validate
            get :get_message
            put :approve
            put :reject
          end
        end
        
        resources :locations
        resources :messages do
          collection do
            get :types
            get :drafts                    
            get :queued
            get :waiting_for_approval
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
            put :send_for_approval
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
    resources :template_uploads

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

    resource :app do
      member do
        get :fetch_code
      end
    end

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
        get "add_more_user"
      end
    end
    resources :locations
    resources :social_profiles do
      member do
        get :add
      end
    end
    resources :dashboards
    resources :file_imports
    resource :shop do
      member do
        get :check_identifier
        put :update_affiliate_tracking #put '/shop/:id/update_affiliate_tracking', to: 'shops#update_affiliate_tracking', as: :update_affiliate_tracking_shop
      end

    end

    
    resource :subscription
    get '/upgrade' => 'subscriptions#upgrade', as: :upgrade_subscription
    get '/invoice' => 'subscriptions#invoice', as: :subsciption_invoice
    get '/invoice/print' => 'subscriptions#print', as: :invoice_print
    put '/subscribe' => 'subscriptions#subscribe', as: :subscribe
    get '/edit_billing_info' => 'subscriptions#edit_billing_info'
    put '/update_billing_info' => 'subscriptions#update_billing_info'
    match '/segments/select_survey' => 'survey_answers#select_survey'

    resources :surveys, only: [:new, :index, :show, :edit, :update], path: :segments do
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

    get "messages/new/template_message" => "messages#new_template", as: 'new_template'
    get "messages/new/:message_type" => 'messages#new', as: 'new_campaign'
    get "messages/" => "messages#types", as: 'campaign_types'
    get 'messages/:id/system_layout_properties/:template_id', to: 'messages#system_layout_properties', as: 'system_layout_properties'
    put 'messages/:id/settable_properties_preview/:template_id', to: 'messages#settable_properties_preview', as: 'selectable_properties_preview'
    get 'messages/:id/default_settable_properties_preview/:template_id', to: 'messages#default_settable_properties_preview', as: 'default_settable_properties_preview'
    resources :messages do
      collection do
        get :select_survey
        get :types
        get :drafts
        get :trash
        get :sent
        get :queued
        put :move_to_trash
        put :move_to_draft
        put :discard
        get :remove_message_image        
      end

      member do
        get :preview
        get :launch
        put :update_meta
        put :create_response_message
        delete :discard_response_message
        get :report
        get :social_report
        put :update_header
        get :edit_template
        get :template
        put :assign_template
        get :show_template
        get :preview_template
        get :preview_template_content
        get :editor
        put :save
        get :email_self
        post :template_upload_image
        post :upload_template_image
        put :upload_template_image
        delete :destroy_template
        get :click_report
        get :email_report
        get :system_layouts
        get :copy
      end #end of member
    end #end of resources messages
  end #end of merchants namespace

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
  get 'l' => 'email_trackings#index'
end
