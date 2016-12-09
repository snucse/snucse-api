Rails.application.routes.draw do
  apipie
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      resources :articles do
        member do
          post :add_tag
          post :destroy_tag
          post :recommend
        end
      end
      resources :comments do
        collection do
          get :replies
        end
        member do
          post :recommend
        end
      end
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
      resources :profile_comments do
        member do
          post :recommend
        end
      end
      namespace :users do
        post :sign_in
        post :sign_up
        get :me
        get ':id/profile_image', to: :show_profile_image
        post :profile_image, to: :upload_profile_image
        delete :profile_image, to: :destroy_profile_image
      end
      namespace :tags do
        get "", to: :index
        get :recent
        get :show
        post :add_related_tag
        post :destroy_related_tag
      end
      namespace :search do
        get "", to: :index
        get :article
        get :comment
        get :profile
        get :tag
      end
      resources :feeds, only: :index
      resources :files, only: :show
    end
  end
end
