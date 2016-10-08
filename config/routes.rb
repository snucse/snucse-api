Rails.application.routes.draw do
  apipie
  namespace :api do
    namespace :v1 do
      resources :articles, defaults: {format: :json}
      resources :comments, defaults: {format: :json}
      resources :profiles, except: :destroy, defaults: {format: :json} do
        collection do
          get :following
        end
        member do
          post :follow
          post :unfollow
          post :transfer
        end
      end
      namespace :users, defaults: {format: :json} do
        post :sign_in
        post :sign_up
        get :me
      end
      resources :feeds, only: :index, defaults: {format: :json}
    end
  end
end
