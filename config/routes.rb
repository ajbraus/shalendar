Shalendar::Application.routes.draw do
  authenticated :user do
    root :to => 'shalendar#home'
  end

  root :to => 'static_pages#landing'

  devise_for :users 

  match '/manage_follows', :to => 'shalendar#manage_follows', :as => "manage_follows"

  resources :events

  resources :rsvps, only: [:create, :destroy]
  
  resources :relationships, only: [:create, :destroy] do
    put :toggle
    delete :remove
  end

  # match '/manage_follows/remove', :to => 'relationships#remove', :as => "remove"


  match '/about', :to => 'static_pages#about', :as => "about"
  match '/contact', :to => 'static_pages#contact', :as => "contact"
  

  match '/my_events', :to => 'events#my_events', :as => "my_events"
  match '/my_plans', :to => 'events#my_plans', :as => "my_plans"
  match '/my_maybes', :to => 'events#my_maybes', :as => "my_maybes"

  match '/my_untipped_events', :to => 'events#my_untipped_events', :as => "my_untipped_events"
  match '/my_untipped_plans', :to => 'events#my_untipped_plans', :as => "my_untipped_plans"
  match '/my_untipped_maybes', :to => 'events#my_untipped_maybes', :as => "my_untipped_maybes"

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
