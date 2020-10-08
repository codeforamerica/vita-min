Rails.application.routes.draw do
  def scoped_navigation_routes(context, navigation)
    scope context, as: context do
      navigation.controllers.uniq.each do |controller_class|
        { get: :edit, put: :update }.each do |method, action|
          match "/#{controller_class.to_param}",
                action: action,
                controller: controller_class.controller_path,
                via: method
        end
      end
      yield if block_given?
    end
  end

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
        (QuestionNavigation.controllers + EipOnlyNavigation.controllers).uniq.each do |controller_class|
          { get: :edit, put: :update }.each do |method, action|
            match "/#{controller_class.to_param}",
                  action: action,
                  controller: controller_class.controller_path,
                  via: method
          end
        end
      end
    end

    resources :documents, only: [:destroy], controller: :documents do
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

    resources :signups, only: [:new, :create]
    get "/sign-up", to: "signups#new"

    # FSA routes
    scoped_navigation_routes(:diy, DiyNavigation) do
      root "public_pages#diy_home"
      get "/:token", to: "diy/start_filing#start", as: :start_filing
    end

    # Stimulus routes
    scoped_navigation_routes(:stimulus, StimulusNavigation)

    get '/diy/check-email', to: 'public_pages#check_email'

    get "/:organization/drop-off", to: "intake_site_drop_offs#new", as: :new_drop_off
    post "/:organization/drop-offs", to: "intake_site_drop_offs#create", as: :create_drop_off
    get "/:organization/drop-off/:id", to: "intake_site_drop_offs#show", as: :show_drop_off

    get "/other-options", to: "public_pages#other_options"
    get "/maybe-ineligible", to: "public_pages#maybe_ineligible"
    get "/maintenance", to: "public_pages#maintenance"
    get "/privacy", to: "public_pages#privacy_policy"
    get "/about-us", to: "public_pages#about_us"
    get "/tax-questions", to: "public_pages#tax_questions"
    get "/faq", to: "public_pages#faq"
    get "/stimulus", to: "public_pages#stimulus"
    get "/full-service", to: "public_pages#full_service_home"
    get "/eip", to: "public_pages#eip_home"
    get "/EIP", to: "public_pages#eip_home"
    get "/500", to: "public_pages#internal_server_error"
    get "/422", to: "public_pages#internal_server_error"
    get "/404", to: "public_pages#page_not_found"

    # Routes to support a simple URL for mailings from Benefits Data Trust (BDT) to their clients
    # And for 211 hotline referrals to both full service and EIP
    # And for FreshEBT (aka Propel) for in-app referrals to EIP
    # These routes point people to the desired landing pages with the proper source tracking
    # They can be removed after 10/15/20. When these routes are removed they'll go to the homepage so won't be broken.
    get "/bdt", to: "public_pages#eip_home", defaults: {"s": "bdt"}
    get "/BDT", to: "public_pages#eip_home", defaults: {"s": "bdt"}
    get "/211", to: "public_pages#full_service_home", defaults: {"s": "211"}
    get "/211-stimulus", to: "public_pages#eip_home", defaults: {"s": "211-stimulus"}
    get "/211-Stimulus", to: "public_pages#eip_home", defaults: {"s": "211-stimulus"}
    get "/FreshEBT", to: "public_pages#eip_home", defaults: {"s": "propel-eip"}
    get "/freshEBT", to: "public_pages#eip_home", defaults: {"s": "propel-eip"}
    get "/freshebt", to: "public_pages#eip_home", defaults: {"s": "propel-eip"}

    # Zendesk Admin routes
    get "/zendesk/sign-in", to: "zendesk#sign_in", as: :zendesk_sign_in
    namespace :zendesk do
      resources :tickets, only: [:show]
      resources :documents, only: [:show]
      resources :drop_offs, only: [:show]
      resources :intakes, only: [:pdf, :consent_pdf] do
        get "13614c/:filename", to: "intakes#intake_pdf", on: :member, as: :pdf
        get "consent/:filename", to: "intakes#consent_pdf", on: :member, as: :consent_pdf
        get "banking-info", to: "intakes#banking_info", on: :member, as: :banking_info
      end
      resources :anonymized_intake_csv_extracts, only: [:index, :show], path: "/csv-extracts", as: :csv_extracts
    end

    # New Case Management Admin routes
    namespace :case_management do
      resources :clients, only: [:index, :show, :create] do
        resources :documents, only: [:index, :edit, :update, :show]
        resources :notes, only: [:create, :index]
        resources :messages, only: [:index]
        resources :outgoing_text_messages, only: [:create]
        resources :outgoing_emails, only: [:create]
      end
    end

    devise_for :users, skip: :omniauth_callbacks, controllers: {
      sessions: "users/sessions",
      invitations: "users/invitations"
    }
    resources :users, only: [:index, :edit, :update]
    get "/users/invitations" => "invitations#index", as: :invitations
    get "/users/profile" => "users#profile", as: :user_profile

    ### END Case Management Admin routes

    # Any other top level slash just goes to home as a source parameter
    get "/:source" => "public_pages#home", constraints: { source: /[0-9a-zA-Z_-]{1,100}/ }
  end

  # Routes outside of the locale scope are not internationalized
  # Omniauth routes
  devise_for :users, only: :omniauth_callbacks, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  get "/auth/failure", to: "users/omniauth_callbacks#failure", as: :omniauth_failure

  # Twilio webhook routes
  post "/outgoing_text_messages/:id", to: "twilio_webhooks#update_outgoing_text_message", as: :outgoing_text_message
  post "/incoming_text_messages", to: "twilio_webhooks#create_incoming_text_message", as: :incoming_text_messages
  # Mailgun webhook routes
  post "/incoming_emails", to: "mailgun_webhooks#create_incoming_email", as: :incoming_emails

  resources :ajax_mixpanel_events, only: [:create]
  post "/zendesk-webhook/incoming", to: "zendesk_webhook#incoming", as: :incoming_zendesk_webhook
  post "/email", to: "email#create"
end
