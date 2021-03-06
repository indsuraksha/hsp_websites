require "domain_conditions"

HarmanSignalProcessingWebsite::Application.routes.draw do

  get "robots" => "main#robots", defaults: { format: 'txt' }
  get "signups/new"
  get "signup/complete" => "signups#complete", as: :signup_complete
  get "epedal_labels/index"

  get "warranty" => "support#warranty_policy"
  get "register" => "support#warranty_registration"

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :brands, only: [:index, :show] do
        collection { get :for_employee_store }
        member { get :service_centers }
      end
      resources :product_families, :products
      get '/brand_features/:id' => 'products#features', as: :brand_features
    end
    namespace :v2 do
      resources :brands, only: [:index, :show] do
        resources :softwares, as: :software, only: [:index, :show]
        resources :products, only: [:index, :show]
      end
      resources :products, only: :show # for backwards compat
    end
  end

  constraints(ToolkitDomain) do
    get '/' => 'toolkit#index', as: :toolkit_root
    devise_for :toolkit_users,
      path: "users",
      class_name: "User",
      controllers: {
        sessions: "toolkit/users/sessions",
        registrations: "toolkit/users/registrations",
        confirmations: "toolkit/users/confirmations",
        passwords: "toolkit/users/passwords",
        unlocks: "toolkit/users/unlocks"
      }
    devise_scope :toolkit_user do
      get '/users/sign_up/:signup_type' => 'toolkit/users/registrations#new', as: :new_toolkit_user
      get '/new_user' => 'toolkit/users/registrations#select_signup_type', as: :select_signup_type
    end
    namespace :toolkit do
      resources :brands, only: :show do
        resources :products, :promotions, only: [:index, :show]
        resources :product_families, :toolkit_resources, :toolkit_resource_types, only: [:show]
      end
    end
  end

  # Removed for rails4.1 (conflicts with custom routes below)
  # resources :registered_downloads
  # debugging help
  get "/site_info" => 'main#site_info'
  get '/resource/:id' => "site_elements#show", as: :site_resource

  devise_for :artists, controllers: { registrations: "artist_registrations" }
  devise_scope :artists do
    get 'artists', to: 'artists#index', as: :artist_root
  end

  match '/activate(/:software_name(/:challenge))' => 'softwares#activate', as: :software_activation, via: :all

  match '/:registered_download_url/register(/:code)' => 'registered_downloads#register', as: :register_to_download, via: :all
  match '/:registered_download_url/confirm' => 'registered_downloads#confirmation', as: :confirm_download_registration, via: :all
  match '/:registered_download_url/get_it/:download_code' => 'registered_downloads#show', as: :registered_download, via: :all
  match '/:registered_download_url/downloadr/:download_code' => 'registered_downloads#download', as: :registered_download_file, via: :all

  get '/favicon.ico' => 'main#favicon'
  get '/dashboard' => 'admin#index', as: :dashboard
  get "/admin" => "admin#index", as: :admin_root, locale: I18n.default_locale
  get 'sitemap(.:format)' => 'main#sitemap', as: :sitemap

  # An example of a custom top-level landing page route:
  # match "/switchyourthinking" => "pages#show", custom_route: "switchyourthinking", locale: I18n.default_locale

  # Legacy links redirected to current links. The constant "_REDIRECTS" are found in
  # config/initializers/redirects.rb
  # These are only needed for site-specific routing (where you don't want a particular URL
  # to work on the other sites)
  constraints(DigitechDomain) do
    # match '/soundcomm(/:page)', to: redirect("/#{I18n.default_locale}/soundcomm"), as: :soundcomm, locale: I18n.default_locale
    match '/soundcomm(/:page)', to: redirect('http://soundcommunity.digitech.com/'), as: :soundcomm, locale: I18n.default_locale, via: :all
    get 'gctraining' => 'pages#gctraining'
    get 'epedal_labels/fulfilled/:id/:secret_code' => 'label_sheet_orders#fulfill', as: :label_sheet_order_fulfillment
    get 'epedal_labels/new(/:epedal_id)' => 'label_sheet_orders#new', as: :epedal_labels_order_form
    get 'epedal_label_thanks' => 'label_sheet_orders#thanks', as: :thanks_label_sheet_order
    resources :label_sheet_orders, only: [:new, :create]
  end

  constraints(CrownDomain) do
    get '/trucktourgiveaway(.:format)' => 'signups#new', defaults: { campaign: "Crown-TruckTour-Flip-2015" }
    get '/solutions' => 'pages#solutions'
  end

  constraints(BssDomain) do
    get '/solutions' => 'pages#solutions'
    get '/en-US/bss-network-audio' => 'pages#solutions'
    get '/en/bss-network-audio' => 'pages#solutions'
  end

  # The constraint { locale: /#{WebsiteLocale.all_unique_locales.join('|')}/ } limits the locale
  # to those configured in the WebsiteLocale model which is configured in the admin area and reverts
  # to AVAILABLE_LOCALES in config/initializers/i18n.rb in case of problems

  # Main routing
  root to: 'main#default_locale'
  scope "(:locale)", locale: /#{WebsiteLocale.all_unique_locales.join('|')}/ do
    scope "/admin" do
      devise_for :users, path: :site_users
      devise_scope :user do
        get 'admin', to: 'admin#index', as: :user_root
      end
    end
    namespace :admin do
      match "brand_toolkit_contacts/load_user/:id" => 'brand_toolkit_contacts#load_user', via: :all
      get 'show_campaign/:id' => 'signups#show_campaign', as: 'show_campaign'
      resources :products do
        collection do
          get :rohs
          put :update_rohs
          get :harman_employee_pricing
          put :update_harman_employee_pricing
          get :artist_pricing
        end
        member do
          get :delete_background
        end
      end
      resources :product_families do
        collection { post :update_order }
        member do
          get :delete_background, :delete_family_photo, :delete_family_banner, :delete_title_banner
        end
      end
      resources :warranty_registrations do
        collection { put :search }
      end
      resources :product_family_products do
        collection { post :update_order }
      end
      resources :product_attachments do
        collection { post :update_order }
      end
      resources :product_documents do
        collection { post :update_order }
      end
      resources :artists do
        collection do
          post :update_order
        end
        member { post :reset_password }
      end
      resources :settings do
        collection do
          get :homepage
          post :update_slides_order
          post :update_features_order
          post :big_bottom_box
        end
        member do
          get :copy
        end
      end
      resources :effect_types, only: [:create] do
        collection { post :update_order }
      end
      resources :users do
        member do
          post :reset_password
        end
      end
      resources :download_registrations do
        member do
          get :reset_and_resend
        end
      end
      resources :registered_downloads do
        member do
          get :send_messages
        end
      end
      resources :product_specifications do
        member do
          post :copy
        end
        collection do
          post :update_order
        end
      end
      resources :market_segments do
        member do
          get :delete_banner_image
        end
        collection do
          post :update_order
        end
      end
      resources :market_segment_product_families do
        collection { post :update_order }
      end
      resources :product_training_modules, :software_training_modules, :parent_products, :product_softwares, :brand_toolkit_contacts do
        collection { post :update_order }
      end
      resources :label_sheet_orders do
        collection { get :subscribers }
      end
      resources :product_prices do
        collection { put :update_all }
      end
      resources :toolkit_resources do
        member { get :delete_preview }
      end
      resources :news do
        member { put :notify }
      end
      resources :softwares do
        collection { post :upload }
      end
      resources :systems do
        resources :system_options do
          resources :system_option_values
        end
        resources :system_components
        resources :system_rules do
          collection do
            put :enable_all
            put :disable_all
          end
          resources :system_rule_condition_groups do
            resources :system_rule_conditions
          end
          resources :system_rule_actions
        end
      end
      resources :system_options do
        collection { post :update_order }
      end
      resources :support_subjects
      resources :service_centers,
        :software_training_classes,
        :product_training_classes,
        :product_review_products,
        :locale_product_families,
        :toolkit_resource_types,
        :product_site_elements,
        :product_introductions,
        :online_retailer_links,
        :online_retailer_users,
        :tone_library_patches,
        :software_attachments,
        :product_audio_demos,
        :product_suggestions,
        :product_amp_models,
        :tone_library_songs,
        :product_promotions,
        :product_cabinets,
        :online_retailers,
        :training_classes,
        :training_modules,
        :product_effects,
        :website_locales,
        :product_reviews,
        :artist_products,
        :faq_categories,
        :us_rep_regions,
        :specifications,
        :installations,
        :pricing_types,
        :site_elements,
        :news_products,
        :label_sheets,
        :distributors,
        :artist_tiers,
        :audio_demos,
        :promotions,
        :amp_models,
        :us_regions,
        :demo_songs,
        :cabinets,
        :websites,
        :captchas,
        :us_reps,
        :effects,
        :signups,
        :dealers,
        :brands,
        :pages,
        :faqs

      #match "translations/:target_locale(/:action)" => "content_translations", as: :translations
      scope path: '/:target_locale', target_locale: /#{WebsiteLocale.all_unique_locales.join('|')}/ do
        resources :content_translations do
          collection {get :list, :combined}
          collection {post :combined}
        end
      end

    end # end admin scope

    # constraints(DigitechDomain) do
    #   mount Forem::Engine, at: "/soundcomm"
    # end
    get 'teaser' => 'main#teaser'
    get 'teaser2' => 'main#teaser'
    resources :signups, only: [:new, :create]
    get 'now-youll-know' => 'main#teaser_complete', as: :teaser_complete
    resources :us_reps, :distributors, only: [:index, :show] do
      collection { get :search }
    end
    # get "distributors#search"
    resources :softwares, only: [:index, :show] do
      member { get :download }
    end
    resources :news, only: [:index, :show] do
      collection { get :archived }
    end
    resources :systems, only: [:index, :show] do
      resources :system_configurations, only: [:new, :create, :edit, :update] do
        member do
          post :new
          match ':access_hash/contact' => 'system_configurations#contact_form', as: :contact_form, via: [:get, :post]
          get ':access_hash' => 'system_configurations#show', as: :show
        end
      end
    end
    resources :faq_categories, only: [:index, :show]
    get "faqs" => 'faq_categories#index', as: :faqs
    get "artists/become_an_artist" => 'artists#become', as: :become_an_artist
    get "artists/all(/:letter)" => 'artists#all', as: :all_artists
    resources :artists, only: [:index, :show] do
      collection {
        get :list
        get :touring
      }
    end
    resources :training_modules, :training_classes, only: [:index, :show]
    get 'training' => 'support#training', as: :training
    resources :market_segments,
      :pages,
      :installations,
      :product_reviews,
      :product_families,
      :demo_songs,
      :promotions, only: [:index, :show]
    get 'introducing/:id' => 'products#introducing', as: :product_introduction
    get 'products/songlist/:id.:format' => 'products#songlist', as: :product_songlist
    resources :products, only: [:index, :discontinued] do
      member do
        get :buy_it_now
        get :songlist
        get :preview
        put :preview
      end
      collection do
        match :compare, via: :all
      end
    end
    get 'products/:id(/:tab)' => 'products#show', as: :product
    resources :tone_library_songs, only: :index
    resources :product_documents, only: :index

    get 'privacy_policy.html' => 'main#privacy_policy', as: :privacy_policy
    get 'terms_of_use.html' => 'main#terms_of_use', as: :terms_of_use

    get 'discontinued_products' => 'products#discontinued_index', as: :discontinued_products
    get 'channel' => 'main#channel'
    get "videos(/:id)" => "videos#index", as: :videos
    get "videos/play/:id" => "videos#play", as: :play_video
    get '/zips/:download_type.zip' => 'support#zipped_downloads', as: :zipped_downloads
    match '/product_documents(/:language(/:document_type))' => "product_documents#index", via: :all
    match '/downloads(/:language(/:document_type))' => "product_documents#index", as: :downloads, via: :all
    get '/support_downloads' => "support#downloads", as: :support_downloads
    match '/tone_library/:product_id/:tone_library_song_id(.:ext)' => "tone_library_songs#download", as: :tone_download, via: :all
    match '/tone_library' => "tone_library_songs#index", as: :tone_library, via: :all
    match '/software' => 'softwares#index', as: :software_index, via: :all
    match '/support/warranty_registration(/:product_id)' => 'support#warranty_registration', as: :warranty_registration, via: :all
    match '/support/parts' => 'support#parts', as: :parts_request, via: :all
    match '/support/rma' => 'support#rma', as: :rma_request, via: :all
    match '/catalog_request' => 'support#catalog_request', as: :catalog_request, via: :all
    get '/support/warranty_policy' => 'support#warranty_policy', as: :warranty_policy
    match '/international_distributors' => 'distributors#index', as: :international_distributors, via: :all
    match '/sitemap(.:format)' => 'main#locale_sitemap', as: :locale_sitemap, via: :all
    match '/where_to_buy(/:zip)' => 'main#where_to_buy', as: :where_to_buy , via: :all
    match '/support(/:action(/:id))' => "support", as: :support, via: :all
    match '/community' => 'main#community', as: :community, via: :all
    match '/rss(.:format)' => 'main#rss', as: :rss, via: :all, defaults: { format: :xml }
    match '/search' => 'main#search', as: :search, via: :all
    match '/rohs' => 'support#rohs', as: :rohs, via: :all
    match 'distributors_for/:brand_id' => 'distributors#minimal', as: :minimal_distributor_search, via: :all
    get 'tools/calculators'
    match '/' => 'main#index', as: :locale_root, via: :all
    match '/:controller(/:action(/:id))', via: :all
    match "*custom_route" => "pages#show", as: :custom_route, via: :all
  end


  match '*a', to: 'errors#404', via: :all

end
