Rails.application.routes.draw do
  apipie
  namespace :api do
    namespace :v1 do
      resources :articles, defaults: {format: :json}
      resources :groups, only: [:index, :show], defaults: {format: :json} do
        collection do
          get :following
        end
        member do
          post :follow
          post :unfollow
        end
      end
      post 'users/sign_in'
    end
  end
end
