Shalendar::Application.routes.draw do

  resources :authentications, :only => [:destroy]
  # match '/auth/:authentication/callback' => 'authentications#create' 
  
  authenticated :user do
    root :to => 'shalendar#home'
  end

  resources :users, :only => [:show]

  City.all.each do |c|
    match "/#{c.name.split(',')[0].gsub(/\s+/, "").downcase}", :to => 'shalendar#home', :as => "#{c.name.split(',')[0].gsub(/\s+/, "").gsub("-", "_").downcase}", :city => "#{c.name}"
  end
  
  root :to => 'static_pages#landing'

  devise_for :users, 
             controllers:   { omniauth_callbacks: "users/omniauth_callbacks", 
                            registrations: "registrations",
                            sessions: "sessions"
                            }, 
             path: "user",
             path_names:    { sign_in: "login",
                              sign_out: "logout"
                            } 
  devise_scope :user do
    match '/new_venue', to: 'registrations#new_vendor', as: "new_vendor"
  end

  # "Route Globbing" patch https://github.com/plataformatec/devise/wiki/OmniAuth%3A-Overview
  devise_scope :user do
    get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
    
    namespace :api do
      namespace :v1 do
        #problem... POST/DELETE requests are being processed as GET..
        #resources :tokens, :only => [:create, :destroy]
        resources :sessions, :only => [:create, :destroy]
        resources :registrations, :only => [:create, :destroy]
        #resources :relationships, :only => [:create]
        #resources :rsvps, :only => [:create]
        #resources :events, :only => [:create] 
        
        match '/relationships', :to => 'relationships#create'
        match '/tokens', :to => 'tokens#create'
        match '/invitations', :to => 'invitations#create'
        match '/invite_all_friends', :to => 'invitations#invite_all_friends'
        match '/create_event', :to => 'events#mobile_create'
        #match '/add_photo_to_event', :to => 'events#add_photo'
        match '/add_comment', :to => 'events#add_comment'
        match '/cancel_idea', :to => 'events#cancel_idea'
        #took out delete and post types bc not working from iphone http reqeust
        match '/rsvps', :to => 'rsvps#create'
        match '/unrsvp', :to => 'rsvps#destroy'#, :via => :delete
        match '/unfollow', :to => 'relationships#destroy'#, :via => :delete
        match '/get_user_info', :to => 'shalendar#get_user_info', :via => :get
        match '/apn_user', :to=> 'tokens#apn_user', :as => "apn_user"#, :via => :post
        match '/gcm_user', :to=> 'tokens#gcm_user', :as => "gcm_user"#, :via => :post

        match '/user_events_on_date', :to => 'events#user_events_on_date', :as => "user_events_on_date", :via => :get
        match '/event_details', :to => 'events#event_details', :as => "event_details", :via => :get
        match '/followed_users', :to => 'shalendar#followed_users', :as => "followed_users", :via => :get
        match '/followers', :to => 'shalendar#followers', :as => "followers", :via => :get
      end
      namespace :v2 do
        #problem... POST/DELETE requests are being processed as GET..
        #resources :tokens, :only => [:create, :destroy]
        resources :sessions, :only => [:create, :destroy]
        resources :registrations, :only => [:create, :destroy]
        #resources :relationships, :only => [:create]
        #resources :rsvps, :only => [:create]
        #resources :events, :only => [:create] 
        
        match '/relationships', :to => 'relationships#create'
        match '/tokens', :to => 'tokens#create'
        match '/invitations', :to => 'invitations#create'
        match '/invite_all_friends', :to => 'invitations#invite_all_friends'
        match '/create_event', :to => 'events#mobile_create'
        #match '/add_photo_to_event', :to => 'events#add_photo'
        match '/add_comment', :to => 'events#add_comment'
        match '/cancel_idea', :to => 'events#cancel_idea'
        #took out delete and post types bc not working from iphone http reqeust
        match '/rsvps', :to => 'rsvps#create'
        match '/unrsvp', :to => 'rsvps#destroy'#, :via => :delete
        match '/unfollow', :to => 'relationships#destroy'#, :via => :delete
        match '/get_user_info', :to => 'shalendar#get_user_info', :via => :get
        match '/apn_user', :to=> 'tokens#apn_user', :as => "apn_user"#, :via => :post
        match '/gcm_user', :to=> 'tokens#gcm_user', :as => "gcm_user"#, :via => :post

        match '/user_events_on_date', :to => 'events#user_events_on_date', :as => "user_events_on_date", :via => :get
        match '/event_details', :to => 'events#event_details', :as => "event_details", :via => :get
        match '/followed_users', :to => 'shalendar#followed_users', :as => "followed_users", :via => :get
        match '/followers', :to => 'shalendar#followers', :as => "followers", :via => :get
      end
    end
  end

  match '/set_time_zone', :to => 'users#set_time_zone', :as => 'set_time_zone'

  match '/collect_payments', :to => 'payments#new_merchant', :as => 'new_merchant'
  match '/create_merchant', :to => 'payments#create_merchant', :as => 'create_merchant'

  match '/confirm_payment', :to => 'payments#confirm_payment', :as => "confirm_payment"
  match '/submit_paytment', :to => 'payments#submit_payment', :as => "submit_payment"

  match '/payment', :to => 'payments#new_card', :as => 'new_card'
  match '/create_card', :to => 'payments#create_card', :as => 'create_card'

  match '/downgrade', :to => 'payments#downgrade', :as =>'downgrade'
  match '/upgrade', :to => 'payments#upgrade', :as => 'upgrade'

  match '/make_a_group', :to => 'events#make_a_group', :as => 'make_a_group'
  match '/repeat', :to => 'events#repeat', :as => 'repeat_event'
  match '/new_crowd_idea', :to => 'events#new_crowd_idea', :as => 'new_crowd_idea'

  match '/activity', :to => 'shalendar#activity', :as => "activity"
  match '/manage_friends', :to => 'shalendar#manage_friends', :as => "manage_friends"

  resources :events, path: "ideas", only: [:create, :destroy, :update, :tip, :edit, :new, :show] do #:index,
    put :tip
    resources :comments, only: [:create, :destroy]
    resources :email_invites, only: [:create, :destroy]
    resources :fb_invites, only: [:create, :destroy]
  end

  resources :rsvps, only: [:create, :destroy]
  resources :invitations, only: [:create, :destroy]
  resources :relationships, only: [:create, :destroy, :toggle, :comfirm] do
    put :toggle
    delete :ignore
    put :confirm
    put :confirm_and_follow
  end

  match 'tip' => 'events#tip'
  match 'invite_all_friends' => 'shalendar#invite_all_friends'
  match 'invite_all_fb_friends' => 'fb_invites#invite_all_fb_friends'
  match 'post_to_own_fb_wall' => 'events#post_to_own_fb_wall'
  match 'post_to_wall_permissions' => 'shalendar#post_to_wall_permissions'
  match 'friend_requests' => 'shalendar#friend_requests'
  match 'new_invited_events' => 'shalendar#new_invited_events'
  match 'search' => 'shalendar#search'
  match 'datepicker' => "shalendar#datepicker"

  match '/what_is_hoosin', :to => 'shalendar#what_is_hoosin', :as => "what_is_hoosin"
  match '/discover', :to => 'shalendar#discover', :as => "discover"
  match '/admin_dashboard', :to => 'shalendar#admin_dashboard', :as => "admin_dashboard"
  match '/yellow_pages', :to => 'shalendar#yellow_pages', :as => "yellow_pages"
  match '/findfriends', :to => 'shalendar#find_friends', :as => "find_friends"
  match 'share_all_fb_friends' =>'shalendar#share_all_fb_friends'
  match 'friend_all' => 'shalendar#friend_all'

  match '/venue', to: 'static_pages#vendor_splash', as: 'vendor_splash'
  match '/about', :to => 'static_pages#about', :as => "about"
  match '/careers', :to => 'static_pages#careers', :as => "careers"
  match '/terms', :to => 'static_pages#terms_header', :as => "terms"

  #FOR MOBILE W USER AUTO USER(3)
  match '/mobile_plans', :to => 'events#mobile_plans', :as => "mobile_plans"
  match '/mobile_maybes', :to => 'events#mobile_maybes', :as => "mobile_maybes"

  match '/mobile_home', to: 'shalendar#mobile_home', as: "mobile_home"
  match '/mobile_followed_users', to: 'shalendar#mobile_followed_users', as: "mobile_followed_users"
  match '/mobile_toggled_followed_users', to: 'shalendar#mobile_toggled_followed_users', as: "mobile_toggled_followed_users"
  match '/mobile_untoggled_followed_users', to: 'shalendar#mobile_untoggled_followed_users', as: "mobile_untoggled_followed_users"
  match '/mobile_followers', to: 'shalendar#mobile_followers', as: "mobile_followers"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
