Rails.application.routes.draw do
  get 'contact_form/new'

  get 'contact_form/create'

  get '/about', to: 'static_pages#about'
  get '/help', to: 'static_pages#help'
  get '/resources', to: 'static_pages#resources'
  get '/contact', to: 'static_pages#contact'
  post 'contact', to: 'static_pages#contact_send'
  get '/copyright', to: 'static_pages#copyright'
  get '/privacy', to: 'static_pages#privacy'
  get '/linking', to: 'static_pages#linking'


  get '/search', to: 'candidates#search'
  # this can be removed later
  get '/candidates/index', to: 'candidates#search'
#  get 'candidates/show'
#  get '/candidates/:id', to: 'candidates#show'

  get '/constituencies', to: 'candidates#constituencies'
  get '/constituencies/:name', to: 'candidates#index'
  get '/c/:name', to: 'candidates#index'

  get 'welcome/index'
  root 'welcome#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

end
