Shalendar::Application.routes.draw do

  match '/about', :to => 'static_pages#about', :as => "about"
  match '/careers', :to => 'static_pages#careers', :as => "careers"
  match '/terms', :to => 'static_pages#terms_header', :as => "terms"
  match '/admin_dashboard', :to => 'shalendar#admin_dashboard', :as => "admin_dashboard"


  City.all.each do |c| #for all cities
    match "/#{c.name.split(',')[0].gsub(/\s+/, "_").downcase}", :to => 'shalendar#home', :as => "#{c.name.split(',')[0].gsub(/\s+/, "").gsub("-", "_").gsub(".", "_").downcase}", :city => "#{c.name}"
  end

  resources :authentications, :only => [:destroy]
  # match '/auth/:authentication/callback' => 'authentications#create' 
  
  authenticated :user do
    root :to => 'shalendar#home'
  end

  resources :users, :only => [:show] do #for profile page 
    get :autocomplete_city_name, :on => :collection
  end
  
  root :to => 'shalendar#home'

  devise_for :users, 
             controllers:   { omniauth_callbacks: "users/omniauth_callbacks", 
                            registrations: "registrations",
                            sessions: "sessions"
                            }, 
             path: "user",
             path_names:    { sign_in: "login",
                              sign_out: "logout"
                            } 

  # "Route Globbing" patch https://github.com/plataformatec/devise/wiki/OmniAuth%3A-Overview
  devise_scope :user do
    get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
  end

  match '/city_names', :to => 'users#city_names', :as => "city_names"
  match '/get_fb_friends_to_invite', :to => 'events#get_fb_friends_to_invite', :as => 'get_fb_friends_to_invite'
  #match '/repeat', :to => 'events#repeat', :as => 'repeat_event'
  #devise_scope :user do
    #match '/new_venue', to: 'registrations#new_vendor', as: "new_vendor"
  #end

  resources :events, path: "ideas", only: [:create, :destroy, :update, :edit, :new, :show, :new_time, :create_new_time, :edit_time] do #:index,
    get :edit_time
    get :new_time
    put :update
    post :create_new_time
    resources :comments, only: [:create, :destroy]
    resources :email_invites, only: [:create, :destroy]
  end

  match '/new_idea', :to => 'events#new', :as => 'new_idea'

  resources :rsvps, only: [:create, :destroy]
  resources :relationships, only: [:create, :destroy, :toggle, :comfirm ] do
    put :toggle
    delete :ignore
    put :confirm
    put :confirm_and_follow
  end

  match '/ignore_inmate', :to => 'relationships#ignore_inmate', as: 'ignore_inmate'

  match '/findfriends', :to => 'shalendar#find_friends', :as => "find_friends"
  match 'share_all_fb_friends' =>'shalendar#share_all_fb_friends'
  match 'post_to_own_fb_wall' => 'events#post_to_own_fb_wall'
  match 'post_to_wall_permissions' => 'shalendar#post_to_wall_permissions'
  #match 'new_invited_events' => 'shalendar#new_invited_events'
  #match 'plans' => 'shalendar#plans'
  match 'search' => 'shalendar#search'

  #PAYMENTS
  #match '/set_time_zone', :to => 'users#set_time_zone', :as => 'set_time_zone'

  #match '/collect_payments', :to => 'payments#new_merchant', :as => 'new_merchant'
  #match '/create_merchant', :to => 'payments#create_merchant', :as => 'create_merchant'

  #match '/confirm_payment', :to => 'payments#confirm_payment', :as => "confirm_payment"
  #match '/submit_paytment', :to => 'payments#submit_payment', :as => "submit_payment"

  #match '/payment', :to => 'payments#new_card', :as => 'new_card'
  #match '/create_card', :to => 'payments#create_card', :as => 'create_card'

  #match '/downgrade', :to => 'payments#downgrade', :as =>'downgrade'
  #match '/upgrade', :to => 'payments#upgrade', :as => 'upgrade'

  #MOBILE
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
      
      match '/add_friend', :to => 'relationships#create'
      match '/remove_friend', :to => 'relationships#destroy'#, :via => :delete
      match '/add_star', :to => 'relationships#add_star'
      match '/remove_star', :to => 'relationships#remove_star'

      match '/search_for_friends', to: 'relationships#search_for_friends', as: "search_for_friends", via: :get
      match '/search_for_fb_friends', to: 'relationships#search_for_fb_friends', as: "search_for_fb_friends", via: :get


      match '/tokens', :to => 'tokens#create'
      match '/invitations', :to => 'invitations#create'
      match '/invite_all_friends', :to => 'invitations#invite_all_friends'
      match '/create_event', :to => 'events#mobile_create'
      match '/add_time', :to => 'events#add_time'
      match '/add_photo_to_event', :to => 'events#add_photo', :via => [:post, :get]
      match '/add_comment', :to => 'events#add_comment'
      match '/cancel_idea', :to => 'events#cancel_idea'
      #took out delete and post types bc not working from iphone http reqeust
      match '/rsvps', :to => 'rsvps#create'
      match '/unrsvp', :to => 'rsvps#destroy'#, :via => :delete
      match '/flake_out', :to => 'rsvps#flake_out' #this is pretty much rsvps#destroy
      match '/get_user_info', :to => 'shalendar#get_user_info', :via => :get
      match '/apn_user', :to=> 'tokens#apn_user', :as => "apn_user"#, :via => :post
      match '/gcm_user', :to=> 'tokens#gcm_user', :as => "gcm_user"#, :via => :post

      match '/user_events_on_date', :to => 'events#user_events_on_date', :as => "user_events_on_date", :via => :get
      match '/event_details', :to => 'events#event_details', :as => "event_details", :via => :get
      match '/followed_users', :to => 'shalendar#followed_users', :as => "followed_users", :via => :get
      match '/followers', :to => 'shalendar#followers', :as => "followers", :via => :get
      match '/friend_profile', :to => 'relationships#get_profile'
      match '/get_friends', :to => 'relationships#get_friends', :as => "get_friends", :via => :get

      match '/get_ins', :to => 'events#ins', :as => "ins", :via => :get
      match '/get_invites', :to => 'events#invites', :as => "invites", :via => :get
      match '/prune_ins', :to => 'events#prune_ins'
      match '/prune_invites', :to => 'events#prune_invites'
    end
  end
end
