Rails.application.routes.draw do
  root 'public_pages#home'

  mount Cfa::Styleguide::Engine => "/cfa"

  resources :vita_providers, only: [:index, :show]
  get '/vita_provider/map', to: 'vita_providers#map'

  resources :questions, controller: :questions do
    collection do
      QuestionNavigation.controllers.uniq.each do |controller_class|
        { get: :edit, put: :update }.each do |method, action|
          match "/#{controller_class.to_param}",
                action: action,
                controller: controller_class.controller_path,
                via: method
        end
      end
    end
  end

  get '/:organization/drop-off', to: 'intake_site_drop_offs#new', as: :new_drop_off
  post '/:organization/drop-offs', to: 'intake_site_drop_offs#create', as: :create_drop_off
  get '/:organization/drop-off/:id', to: 'intake_site_drop_offs#show', as: :show_drop_off

  get '/overview', to: 'overview#new'
end
