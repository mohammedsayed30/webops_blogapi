require "sidekiq/web"
require "rack/session/cookie"
# Enable sessions ONLY for Sidekiq Web UI
Sidekiq::Web.use Rack::Session::Cookie, secret: Rails.application.secret_key_base
Rails.application.routes.draw do
# Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
mount ActiveStorage::Engine => "/rails/active_storage"
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  mount Sidekiq::Web => "/sidekiq"

  namespace :api do
    namespace :v1 do
      # Define routes for users
      post "users/signup", to: "users#signup"
      post "users/login", to: "users#login"

       # Define routes for posts
       resources :posts do
           resources :comments, only: [ :create, :index ]
           member do
             patch "update_tags"  # PATCH /posts/:id/update_tags
           end
       end
       resources :comments, only: [ :update, :destroy ]
       # special routes for posts
       get ":user_id/posts", to: "posts#user_posts"
       get "myposts", to: "posts#my_posts"
       end
  end

   match "*unmatched", to: "application#route_not_found", via: :all
  # Defines the root path route ("/")
  # root "posts#index"
end
