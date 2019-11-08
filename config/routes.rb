Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'pages#home'

  post 'deploy' => 'webhooks#github_push'

  mount Cfa::Styleguide::Engine => "/cfa"
end
