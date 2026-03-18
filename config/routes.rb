Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'api/sessions',
    registrations: 'api/registrations'
  }, defaults: { format: :json }

  namespace :api, defaults: { format: :json } do
    resources :posts, only: [:index, :create, :show, :destroy] do
      resources :comments, only: [:index, :create]
    end

    resources :comments, only: [:destroy]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
