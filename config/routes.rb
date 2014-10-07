require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  resources :videos do
    collection do
      get 'generate'
      get 'shuffle'
      get 'reanalyze'
      get 'redownload'
      get 'redownload_missing'
    end
    member do
      get 'stream'
      get 'fanart'
      get 'thumbnails'
      post 'left_off_at'
      post 'reanalyze' => 'videos#reanalyze_video'
    end
  end

  resources :settings do
    collection do
      get 'welcome'
    end
  end

  resources :series do
    collection do
      get 'nonepisodic'
      get 'newest_episodes'
      get 'newest_unwatched'
    end
    member do
      get 'find_episode'
      post 'download'
    end
  end
  resources :movies do
    collection do
      get 'remote'
      get '3D', as: 'three_d', action: 'three_d'
      get '2D', as: 'two_d', action: 'two_d'
      get 'newest'
      get 'discover_more'
      get 'genres'
      get 'genres/:type', as: :by_genre, action: :genre
      get 'movie_search', as: :movie_search, action: :movie_search
    end
    member do
      get 'find_sources'
      post 'download'
    end
  end

  resources :torrents, only: [] do
    member do
      get 'status'
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'videos#index'

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
