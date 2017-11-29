Rails.application.routes.draw do
  resources :stats, only: %i[index]

  root to: 'stats#index'
end
