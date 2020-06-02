Rails.application.routes.draw do
  mount Cfa::Styleguide::Engine => "/cfa"

  # All routes in this scope will be prefixed with /locale if an available locale is set. See default_url_options in
  # application_controller.rb and http://guides.rubyonrails.org/i18n.html for more info on this approach.
  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
    get '/:locale' => 'public_pages#home'
    root "public_pages#home"

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

    scope :diy, as: :diy do
      DiyNavigation.controllers.uniq.each do |controller_class|
        { get: :edit, put: :update }.each do |method, action|
          match "/#{controller_class.to_param}",
            action: action,
            controller: controller_class.controller_path,
            via: method
        end
      end
      get "/:token", to: "diy/start_filing#start", as: :start_filing
    end

    get "/:organization/drop-off", to: "intake_site_drop_offs#new", as: :new_drop_off
    post "/:organization/drop-offs", to: "intake_site_drop_offs#create", as: :create_drop_off
    get "/:organization/drop-off/:id", to: "intake_site_drop_offs#show", as: :show_drop_off

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

    # FSA routes
    get '/diy/check-email', to: 'public_pages#check_email'

    # Admin routes
    get "/zendesk/sign-in", to: "zendesk#sign_in", as: :zendesk_sign_in
    namespace :zendesk do
      resources :tickets, only: [:show]
      resources :documents, only: [:show]
      resources :intakes, only: [:pdf, :consent_pdf] do
        get "13614c/:filename", to: "intakes#intake_pdf", on: :member, as: :pdf
        get "consent/:filename", to: "intakes#consent_pdf", on: :member, as: :consent_pdf
        get "banking-info", to: "intakes#banking_info", on: :member, as: :banking_info
      end
    end
  end

  # Routes outside of the locale scope are not internationalized
  resources :ajax_mixpanel_events, only: [:create]
  post "/zendesk-webhook/incoming", to: "zendesk_webhook#incoming", as: :incoming_zendesk_webhook
  post "/email", to: "email#create"

  devise_for :users, controllers: {
      omniauth_callbacks: "users/omniauth_callbacks",
  }
  get "/auth/failure", to: "users/omniauth_callbacks#failure", as: :omniauth_failure
end
