Shalendar::Application.routes.draw do

  resources :authentications, :only => [:destroy]
  # match '/auth/:authentication/callback' => 'authentications#create' 
  
  authenticated :user do
    root :to => 'shalendar#home'
  end

  root :to => 'static_pages#landing'

  devise_for :users, 
             controllers:   { omniauth_callbacks: "users/omniauth_callbacks", 
                            registrations: "registrations",
                            sessions: "sessions"
                            }, 
             path: "user",
             path_names:    { sign_in: "login",
                              sign_out: "logout", 
                              sign_up: "join"
                            } 

  #Autocomplete path for autocomplete gem
  match'/autocomplete_email', to: 'shalendar#autocomplete_user_email', as: "autocomplete_email"

  # "Route Globbing" patch https://github.com/plataformatec/devise/wiki/OmniAuth%3A-Overview
  devise_scope :user do
    get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'

    namespace :api do
      namespace :v1 do
        resources :tokens, :only => [:create, :destroy]
        resources :sessions, :only => [:create, :destroy]
        resources :registrations, :only => [:create, :destroy]
        resources :relationships, :only => [:create, :destroy]
        resources :rsvps, :only => [:create, :destroy]
        
        match '/APNtoken', :to=> 'tokens#APNtoken', :as => "APNtoken", :via => :post
        match '/user_events_on_date', :to => 'events#user_events_on_date', :as => "user_events_on_date", :via => :get
        match '/event_details', :to => 'events#event_details', :as => "event_details", :via => :get
        match '/followed_users', :to => 'shalendar#followed_users', :as => "followed_users", :via => :get
        match '/followers', :to => 'shalendar#followers', :as => "followers", :via => :get
        match '/remove_follower', :to => 'relationships#remove_follower', :as => 'remove_follower', :via => :delete
        match '/confirm_follower', :to => 'relationships#confirm_follower', :as => 'confirm_follower', :via => :post
      end
    end
  end

  match '/manage_follows', :to => 'shalendar#manage_follows', :as => "manage_follows"

  resources :events do
    resources :comments, only: [:create, :destroy]
    resources :invites, only: [:create, :destroy]
  end
  

  resources :rsvps, only: [:create, :destroy]
  
  resources :relationships, only: [:create, :destroy, :toggle, :remove, :comfirm] do
    put :toggle
    delete :remove
    put :confirm
    put :confirm_and_follow
  end

  # invite users from the find_friends lightbox
  match '/invite', :to => 'shalendar#invite', :as => "invite"

  # shalendar#search get request 
  # match '/search', :to => 'shalendar#search', :as => "search"


  match '/user_plans_on_date', :to => 'shalendar#user_plans_on_date', :as => "user_plans_on_date"
  match '/user_ideas_on_date', :to => 'shalendar#user_ideas_on_date', :as => "user_ideas_on_date"
  match '/user_events_on_date', :to => 'shalendar#user_events_on_date', :as => "user_events_on_date"

  # match '/manage_follows/remove', :to => 'relationships#remove', :as => "remove"

  match '/findfriends', :to => 'shalendar#find_friends', :as => "find_friends"
  match '/about', :to => 'static_pages#about', :as => "about"
  match '/contact', :to => 'static_pages#contact', :as => "contact"
  match '/home', to: 'shalendar#home', as: "home"
  
  match '/my_invitations', :to => 'events#my_invitations', :as => "my_invitations"
  match '/my_events', :to => 'events#my_events', :as => "my_events"
  match '/my_plans', :to => 'events#my_plans', :as => "my_plans"
  match '/my_maybes', :to => 'events#my_maybes', :as => "my_maybes"

  match '/my_untipped_invitations', :to => 'events#my_untipped_invitations', :as => "my_untipped_invitations"
  match '/my_untipped_events', :to => 'events#my_untipped_events', :as => "my_untipped_events"
  match '/my_untipped_plans', :to => 'events#my_untipped_plans', :as => "my_untipped_plans"
  match '/my_untipped_maybes', :to => 'events#my_untipped_maybes', :as => "my_untipped_maybes"


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
