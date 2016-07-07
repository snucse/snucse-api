Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :articles, defaults: {format: :json}
      resources :groups, only: [:index, :show], defaults: {format: :json}
    end
  end
end
