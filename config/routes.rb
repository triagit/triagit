admin_constraint = lambda do |request|
  user = User.find request.session[:uid] rescue nil
  return user && user.superadmin?
end

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope '/', module: 'site', as: 'site' do
  	root to: 'home#index'
    resources :docs, only: [:index]
  end

  scope '/github', module: 'github', as: 'github' do
    resources :sessions, only: [:new, :destroy]
    resources :home, only: [:index]
    post :webhook, to: 'webhook#create'
    root to: 'home#index'
  end

  scope '/admin', as: 'admin', constraints: admin_constraint do
    mount Resque::Server.new, at: '/jobs'
  end
  ActiveAdmin.routes(self)

  get '/auth/github/callback', to: 'github/sessions#new'
  get '/health', to: 'site/health#show'
  get '/logout', to: 'site/home#destroy'

  root to: 'site/home#index'
end
