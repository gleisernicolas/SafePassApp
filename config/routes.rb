Rails.application.routes.draw do
  devise_for :users, path: "secure"
  get "home", to: "pages#home"

  root "entries#index"

  get "about", to: "pages#about"

  resources :entries
end
