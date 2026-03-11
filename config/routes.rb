Rails.application.routes.draw do
  devise_for :users

  namespace :api do
    resources :posts, only: [] do
      resources :comments, only: [:index, :create]
  end

  resources :comments, only: [:destroy]
end


 get "up" => "rails/health#show", as: :rails_health_check
end
