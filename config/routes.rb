Rails.application.routes.draw do
  apipie
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      resources :articles do
        member do
          post :add_tag
          post :destroy_tag
        end
      end
      resources :comments
      resources :profiles, except: :destroy do
        collection do
          get :following
        end
        member do
          post :follow
          post :unfollow
          post :transfer
          post :add_tag
          post :destroy_tag
        end
      end
      namespace :users do
        post :sign_in
        post :sign_up
        get :me
      end
      resources :feeds, only: :index
    end
  end
end
