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
      DocumentNavigation.controllers.uniq.each do |controller_class|
        { get: :edit, put: :update }.each do |method, action|
          match "/#{controller_class.to_param}",
                action: action,
                controller: controller_class.controller_path,
                via: method
        end
      end
    end
  end
  namespace :documents do
    delete "/requested-documents-later/remove", to: "requested_documents_later#destroy", as: :remove_requested_document
    get "/requested-documents-later/not-found", to: "requested_documents_later#not_found", as: :requested_docs_not_found
    get "/add/success", to: "send_requested_documents_later#success", as: :requested_documents_success
    get "/add/:token", to: "requested_documents_later#edit", as: :add_requested_documents
  end

  resources :dependents, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :documents, only: [:destroy]
  resources :ajax_mixpanel_events, only: [:create]

  get "/:organization/drop-off", to: "intake_site_drop_offs#new", as: :new_drop_off
  post "/:organization/drop-offs", to: "intake_site_drop_offs#create", as: :create_drop_off
  get "/:organization/drop-off/:id", to: "intake_site_drop_offs#show", as: :show_drop_off

  get "/stimulus-recommendation", to: "public_pages#stimulus_recommendation"
  get "/identity-needed", to: "offboarding#identity_needed"
  get "/other-options", to: "public_pages#other_options"
  get "/maybe-ineligible", to: "public_pages#maybe_ineligible"
  get "/maintenance", to: "public_pages#maintenance"
  get "/at-capacity", to: "public_pages#at_capacity"
  get "/privacy", to: "public_pages#privacy_policy"
  get "/about-us", to: "public_pages#about_us"
  get "/tax-questions", to: "public_pages#tax_questions"
  get "/faq", to: "public_pages#faq"
  get "/stimulus", to: "public_pages#stimulus"
  get "/500", to: "public_pages#internal_server_error"
  get "/422", to: "public_pages#internal_server_error"
  get "/404", to: "public_pages#page_not_found"

  get "/verify-spouse/not-found", to: "spouse_auth_only#not_found"
  get "/verify-spouse/done", to: "spouse_auth_only#spouse_auth_complete"
  get "/verify-spouse/:token", to: "spouse_auth_only#show", as: :verify_spouse

  post "/zendesk-webhook/incoming", to: "zendesk_webhook#incoming", as: :incoming_zendesk_webhook
  post "/email", to: "email#create"
end
