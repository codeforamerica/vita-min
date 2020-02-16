Rails.application.routes.draw do
  root "public_pages#home"

  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    sessions: "users/sessions"
  }
  get "/auth/failure", to: "users/omniauth_callbacks#failure", as: :omniauth_failure

  devise_scope :user do
    get "sign_in", :to => "devise/sessions#new", as: :new_user_session
    delete "sign_out", :to => "users/sessions#destroy", as: :destroy_user_session
    delete "idme_sign_out", :to => "users/sessions#logout_primary_from_idme", as: :destroy_idme_session
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

  resources :documents, controller: :documents do
    collection do
      DocumentNavigation.all_controllers.uniq.each do |controller_class|
        { get: :edit, put: :update }.each do |method, action|
          match "/#{controller_class.to_param}",
                action: action,
                controller: controller_class.controller_path,
                via: method
        end
      end
    end
  end

  resources :dependents, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :documents, only: [:destroy]

  get "/:organization/drop-off", to: "intake_site_drop_offs#new", as: :new_drop_off
  post "/:organization/drop-offs", to: "intake_site_drop_offs#create", as: :create_drop_off
  get "/:organization/drop-off/:id", to: "intake_site_drop_offs#show", as: :show_drop_off

  get "/identity-needed", to: "offboarding#identity_needed"
  get "/other-options", to: "public_pages#other_options"

  post "/email", to: "email#create"
end
