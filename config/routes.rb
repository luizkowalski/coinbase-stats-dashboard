Rails.application.routes.draw do
  resources :stats, only: %i[index] do
    post 'cashout', on: :collection
  end

  resources :sessions, only: %i[index create new]

  root to: 'stats#index'
end
