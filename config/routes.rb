Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope '/', module: 'site', as: 'site' do
  	root to: 'home#index'
  end

  scope '/github', module: 'github', as: 'github' do
    resources :sessions, only: [:new, :destroy]
    resources :home, only: [:index]
    root to: 'home#index'
  end

  scope '/admin' do
    mount Resque::Server.new, at: '/jobs'
  end

  get '/auth/github/callback', to: 'github/sessions#new'
  root to: 'site/home#index'
end
