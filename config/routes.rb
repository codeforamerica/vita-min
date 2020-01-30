Rails.application.routes.draw do
  root "public_pages#home"

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  devise_scope :user do
    get "sign_in", :to => "devise/sessions#new", as: :new_user_session
    delete "sign_out", :to => "devise/sessions#destroy", as: :destroy_user_session
  end

  mount Cfa::Styleguide::Engine => "/cfa"

  resources :vita_providers, only: [:index, :show]
  get "/vita_provider/map", to: "vita_providers#map"

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

  resources :documents, only: [:destroy]

  get "/:organization/drop-off", to: "intake_site_drop_offs#new", as: :new_drop_off
  post "/:organization/drop-offs", to: "intake_site_drop_offs#create", as: :create_drop_off
  get "/:organization/drop-off/:id", to: "intake_site_drop_offs#show", as: :show_drop_off
end
