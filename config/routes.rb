Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
	root to: 'site/home#index'
  scope '/', module: 'site', as: 'site' do
  	root to: 'home#index'
  end
end
