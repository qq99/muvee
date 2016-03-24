# require 'sidekiq/web'

Rails.application.routes.draw do
  # mount Sidekiq::Web => '/sidekiq'
  mount ActionCable.server => "/cable"

  resources :videos, except: [:show] do
    collection do
      get :shuffle
    end
    member do
      get 'source/(:source_id)', action: :show_source, as: :show_source
      get 'source/:source_id/stream', action: :stream_source, as: :stream_source
      get :fanart
      get :thumbnails
      post :reanalyze, action: :reanalyze_video
    end
  end

  resources :lights do
    collection do
      post :dim
      post :brighten
      post :set
    end
  end

  resources :settings do
    collection do
      get :welcome
      get 'reorganize_movies' => 'settings#reorganize_movies_show'
      get :find_dead_files
      get :find_dead_sources
      post :destroy_files
      post :destroy_sources
      post 'reorganize_movies' => 'settings#reorganize_movies_perform'
    end
  end

  resources :series do
    collection do
      get :nonepisodic
      get :newest_episodes
      get :newest_unwatched
      get :show_episode_details
      get :favorites
      get :discover
      get :genres
      get 'genres/:type', as: :by_genre, action: :genre
      get 'actors/:actor', as: :by_actor, action: :actor
      get :search
      post :discover_more
    end
    member do
      get :shuffle
      post 'download/:episode_id', action: :download, as: :download
      post :reanalyze
      post :favorite
      post :unfavorite
    end
  end
  resources :movies do
    collection do
      get :index, action: :all
      get :all
      get :discover
      get :newest
      get :newest_unwatched
      get :favorites
      get :genres
      get 'genres/:type', as: :by_genre, action: :genre
      get 'actors/:actor', as: :by_actor, action: :actor
      get :search
      post :movie_search, as: :movie_search, action: :movie_search
      post :discover_more
    end
    member do
      get :find_sources
      post :download
      patch :override_imdb_id
      post :reanalyze
      post :favorite
      post :unfavorite
    end
  end

  resources :torrents, only: [] do
    member do
      get :status
    end
  end

  resources :status, only: [:index] do
    collection do
      get :info
      post :scan_for_new_media
      post :reanalyze_media
      post :redownload_missing_arts
      post :redownload_all_arts
      delete :destroy_torrent
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'series#index'

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
