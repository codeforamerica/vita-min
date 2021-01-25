Rails.application.routes.draw do
  def scoped_navigation_routes(context, navigation, as_redirects: false)
    scope context, as: context do
      navigation.controllers.uniq.each do |controller_class|
        { get: :edit, put: :update }.each do |method, action|
          if as_redirects
            match "/#{controller_class.to_param}",
                  via: method,
                  to: redirect { |_, request| "/#{request.params[:locale]}" }
          else
            match "/#{controller_class.to_param}",
                  action: action,
                  controller: controller_class.controller_path,
                  via: method
          end
        end
      end
      yield if block_given?
    end
  end

  mount Cfa::Styleguide::Engine => "/cfa"

  # In order to disambiguate versions of english pages with and without locales, we redirect to URLs including the locale
  # If we redirect here in the route declarations, we can't inspect accept headers to determine the proper default locale,
  # hence the redirect actions in public_pages.
  root "public_pages#redirect_locale_home", as: :redirected_root

  # All routes in this scope will be prefixed with /locale if an available locale is set. See default_url_options in
  # application_controller.rb and http://guides.rubyonrails.org/i18n.html for more info on this approach.
  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
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
    scoped_navigation_routes(:diy, DiyNavigation, as_redirects: Rails.configuration.offseason) do
      if Rails.configuration.offseason
        root to: redirect { |_, request| "/#{request.params[:locale]}" }
        get "/:token", to: redirect { |_, request| "/#{request.params[:locale]}" }, as: :start_filing
      else
        root "public_pages#diy_home"
        get "/:token", to: "diy/start_filing#start", as: :start_filing
      end
    end

    # Stimulus routes
    scoped_navigation_routes(:stimulus, StimulusNavigation, as_redirects: Rails.configuration.offseason)

    get "/other-options", to: "public_pages#other_options"
    get "/maybe-ineligible", to: "public_pages#maybe_ineligible"
    get "/maintenance", to: "public_pages#maintenance"
    get "/privacy", to: "public_pages#privacy_policy"
    get "/about-us", to: "public_pages#about_us"
    get "/tax-questions", to: "public_pages#tax_questions"
    get "/faq", to: "public_pages#faq"
    get "/sms-terms", to: "public_pages#sms_terms"
    get "/stimulus", to: "public_pages#stimulus"
    get "/full-service", to: redirect('/')
    get "/eip", to: redirect('/')
    get "/EIP", to: redirect('/')
    get "/500", to: "public_pages#internal_server_error"
    get "/422", to: "public_pages#internal_server_error"
    get "/404", to: "public_pages#page_not_found"

    devise_for :clients, skip: [:sessions]
    namespace :portal do
      root "portal#home"
      resources :client_logins, path: "account", only: [:new, :create, :show, :update] do
        get "locked", to: "client_logins#account_locked", as: :account_locked, on: :collection
        get "link-sent", to: "client_logins#link_sent", as: :login_link_sent, on: :collection
        get "invalid-token", to: "client_logins#invalid_token", as: :invalid_token, on: :collection
      end
      resources :tax_returns, only: [], path: '/tax-returns' do
        get '/sign', to: 'tax_returns#authorize_signature', as: :authorize_signature
        put '/sign', to: 'tax_returns#sign', as: :sign
        get '/spouse-sign', to: 'tax_returns#spouse_authorize_signature', as: :spouse_authorize_signature
        put '/spouse-sign', to: 'tax_returns#spouse_sign', as: :spouse_sign
        get '/success', to: 'tax_returns#success', as: :success
      end
      resources :documents, only: [:show]
    end

    # Hub Admin routes (Case Management)
    namespace :hub do
      root "assigned_clients#index"
      resources :tax_returns, only: [:edit, :update, :show]
      resources :clients do
        get "/organization", to: "clients/organizations#edit", on: :member, as: :edit_organization
        patch "/organization", to: "clients/organizations#update", on: :member, as: :organization
        get "/bai", to: "clients/bank_accounts#show", on: :member, as: :show_bank_account
        get "/hide-bai", to: "clients/bank_accounts#hide", on: :member, as: :hide_bank_account
        resources :documents, only: [:index, :edit, :update, :show, :create, :new]
        resources :notes, only: [:create, :index]
        resources :messages, only: [:index]
        resources :outgoing_text_messages, only: [:create]
        resources :outgoing_emails, only: [:create]
        resources :outbound_calls, only: [:new, :create, :show, :update]
        member do
          patch "attention_needed"
          get "edit_take_action"
          post "update_take_action"
        end
      end

      resources :tax_returns, only: [] do
        patch "update_certification", to: "tax_returns/certifications#update", on: :member
      end
      resources :organizations, only: [:index, :create, :new, :edit, :update]
      resources :sites, only: [:new, :create, :edit, :update]
      resources :anonymized_intake_csv_extracts, only: [:index, :show], path: "/csv-extracts", as: :csv_extracts
      resources :users, only: [:index, :edit, :update]
      get "/profile" => "users#profile", as: :user_profile
    end

    devise_for :users, path: "hub", controllers: {
      sessions: "users/sessions",
      invitations: "users/invitations"
    }
    get "hub/users/invitations" => "invitations#index", as: :invitations
    put "hub/users/invitations/:user_id/resend", to: "invitations#resend_invitation", as: :user_resend_invitation
    ### END Hub Admin routes (Case Management)

    # Any other top level slash just goes to home as a source parameter
    get "/:source" => "public_pages#source_routing", constraints: { source: /[0-9a-zA-Z_-]{1,100}/ }
  end
  # Routes outside of the locale scope are not internationalized

  # Twilio webhook routes
  post "/outgoing_text_messages/:id", to: "twilio_webhooks#update_outgoing_text_message", as: :outgoing_text_message
  post "/outbound_calls/:id", to: "twilio_webhooks#update_outbound_call", as: :outbound_calls_webhook
  post "/incoming_text_messages", to: "twilio_webhooks#create_incoming_text_message", as: :incoming_text_messages
  post "/outbound_calls/connect/:id", to: "twilio_webhooks#outbound_call_connect", as: :twilio_connect_to_client, defaults: { format: "xml" }
  # Mailgun webhook routes
  post "/incoming_emails", to: "mailgun_webhooks#create_incoming_email", as: :incoming_emails

  resources :ajax_mixpanel_events, only: [:create]

  mount ActionCable.server => '/cable'
end
