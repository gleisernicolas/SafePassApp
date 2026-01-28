Rails.application.routes.draw do
  devise_for :users, path: 'secure'
  get 'home', to: 'pages#home'

  root 'pages#home'

  get 'about', to: 'pages#about'
end
