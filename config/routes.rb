Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'pages#home'

  mount Cfa::Styleguide::Engine => "/cfa"

  resources :intake_site_drop_offs, only: [:new, :create, :show]
  resources :vita_providers, only: [:index, :show]
end
