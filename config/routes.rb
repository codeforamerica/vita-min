Rails.application.routes.draw do
  constraints(Routes::GyrDomain.new) do
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
        get "/add/:token", to: redirect { |_, request| "/#{request.params[:locale] || "en"}/portal/login" }, as: :add_requested_documents
        get "/doc-help/:doc_type", to: "documents_help#show", as: :help
        post '/doc-help/send-reminder', to: 'documents_help#send_reminder' # remove after next release
        post '/doc-help/request-doc-help', to: 'documents_help#request_doc_help' # remove after next release
        post '/send-reminder', to: 'documents_help#send_reminder', as: :send_reminder
        post '/request-doc-help', to: 'documents_help#request_doc_help', as: :request_doc_help
      end

      resources :dependents, only: [:index, :new, :create, :edit, :update, :destroy]

      get "/sign-up", to: redirect('/')

      namespace :diy do
        get "/file-yourself", to: "file_yourself#edit"
        get "/email", to: "diy_intakes#new"
        post "/email", to: "diy_intakes#create"
        get "/tax-slayer", to: "tax_slayer#show", as: :tax_slayer
      end

      # Stimulus routes
      scoped_navigation_routes(:stimulus, StimulusNavigation, as_redirects: Rails.configuration.offseason)

      get "/diy", to: "public_pages#diy"
      get "/other-options", to: "public_pages#other_options"
      get "/maybe-ineligible", to: "public_pages#maybe_ineligible"
      get "/maintenance", to: "public_pages#maintenance"
      get "/privacy", to: "public_pages#privacy_policy"
      get "/about-us", to: "public_pages#about_us"
      get "/tax-questions", to: "public_pages#tax_questions"
      get "/faq", to: "public_pages#faq"
      get "/sms-terms", to: "public_pages#sms_terms"
      get "/stimulus", to: "public_pages#stimulus"
      get "/full-service", to: "public_pages#full_service_home"
      get "/eip", to: redirect('/')
      get "/EIP", to: redirect('/')
      get "/500", to: "public_pages#internal_server_error"
      get "/422", to: "public_pages#internal_server_error"
      get "/404", to: "public_pages#page_not_found"
      get "/consent-to-use", to: "consent_pages#consent_to_use"
      get "/consent-to-disclose", to: "consent_pages#consent_to_disclose"
      get "/relational-efin", to: "consent_pages#relational_efin"
      get "/global-carryforward", to: "consent_pages#global_carryforward"

      devise_for :clients, skip: [:sessions]
      namespace :portal do
        root "portal#home"

        # Add redirect for pre-March-2021-style login token links; safe to delete in April 2021
        get "/account/:id", to: redirect { |_, request| "/#{request.params[:locale] || "en"}/portal/login/#{request.params[:id]}"}

        resources :client_logins, path: "login", only: [:new, :create, :edit, :update], path_names: { new: '', edit: ''} do
          get "locked", to: "client_logins#account_locked", as: :account_locked, on: :collection
          put "check-verification-code", to: "client_logins#check_verification_code", as: :check_verification_code, on: :collection
        end
        resources :tax_returns, only: [], path: '/tax-returns' do
          get '/show', to: 'tax_returns#show', as: :show
          get '/sign', to: 'tax_returns#authorize_signature', as: :authorize_signature
          put '/sign', to: 'tax_returns#sign', as: :sign
          get '/spouse-sign', to: 'tax_returns#spouse_authorize_signature', as: :spouse_authorize_signature
          put '/spouse-sign', to: 'tax_returns#spouse_sign', as: :spouse_sign
          get '/success', to: 'tax_returns#success', as: :success
        end
        get '/still-need-help', to: "still_needs_helps#edit", as: :still_needs_help
        put '/still-need-help', to: "still_needs_helps#update", as: :update_still_needs_help
        get '/still-need-help/chat-later', to: "still_needs_helps#chat_later", as: :still_needs_help_chat_later
        get '/still-need-help/thank-you', to: "still_needs_helps#no_longer_needs_help", as: :still_needs_help_no_longer_needs_help
        put '/still-need-help/thank-you', to: "still_needs_helps#experience_survey", as: :still_needs_help_experience_survey
        resources :messages, only: [:new, :create]
        resources :documents, only: [:show]
        resources :upload_documents, only: [:destroy]
        match 'upload-documents', to: 'upload_documents#edit', via: :get, as: :edit_upload_documents
        match 'upload-documents', to: 'upload_documents#update', via: :put
        match 'complete-documents-request', to: 'upload_documents#complete_documents_request', via: :get
      end


    # Hub Admin routes (Case Management)
    namespace :hub do
      root "assigned_clients#index"
      resources :metrics, only: [:index]
      resources :tax_returns, only: [:edit, :update, :show]
      resources :unlinked_clients, only: [:index]
      resources :state_routings, only: [:index, :edit, :update], param: :state do
        delete "/:id", to: "state_routings#destroy", on: :member, as: :destroy
      end
      resources :clients do
        get "/sla-breaches", to: "unattended_clients#index", on: :collection, as: :sla_breaches
        get "/organization", to: "clients/organizations#edit", on: :member, as: :edit_organization
        patch "/organization", to: "clients/organizations#update", on: :member, as: :organization
        patch "/unlock", to: "clients#unlock", on: :member, as: :unlock
        get "/bai", to: "clients/bank_accounts#show", on: :member, as: :show_bank_account
        get "/hide-bai", to: "clients/bank_accounts#hide", on: :member, as: :hide_bank_account
        get "/ssn", to: "clients/ssn_itins#show", on: :member, as: :show_ssn_itin
        get "/hide-ssn", to: "clients/ssn_itins#hide", on: :member, as: :hide_ssn_itin
        get "/spouse-ssn", to: "clients/ssn_itins#show_spouse", on: :member, as: :show_spouse_ssn_itin
        get "/hide-spouse-ssn", to: "clients/ssn_itins#hide_spouse", on: :member, as: :hide_spouse_ssn_itin
        resources :documents do
          get "/archived", to: "documents#archived", on: :collection, as: :archived
          get "/confirm", to: "documents#confirm", on: :member, as: :confirm
        end
        resources :notes, only: [:create, :index]
        resources :messages, only: [:index]
        resources :outgoing_text_messages, only: [:create]
        resources :outgoing_emails, only: [:create]
        resources :outbound_calls, only: [:new, :create, :show, :update]
        resources :tax_returns, only: [:new, :create]
        member do
          patch "flag"
          get "edit_take_action"
          post "update_take_action"
        end
      end
      resources :ctc_clients, only: [:new, :create]

        resources :tax_return_selections, path: "tax-return-selections", only: [:create, :show, :new]

        resources :bulk_client_messages, path: "bulk-client-messages", only: [:show]

        namespace :bulk_actions, path: "bulk-actions" do
          get "/:tax_return_selection_id/change-organization", to: "change_organization#edit", as: :edit_change_organization
          put "/:tax_return_selection_id/change-organization", to: "change_organization#update", as: :update_change_organization

          get "/:tax_return_selection_id/send-a-message", to: "send_a_message#edit", as: :edit_send_a_message
          put "/:tax_return_selection_id/send-a-message", to: "send_a_message#update", as: :update_send_a_message

          get "/:tax_return_selection_id/change-assignee-and-status", to: "change_assignee_and_status#edit", as: :edit_change_assignee_and_status
          put "/:tax_return_selection_id/change-assignee-and-status", to: "change_assignee_and_status#update", as: :update_change_assignee_and_status
        end

        resources :zip_codes, only: [:create, :destroy]
        resources :source_params, only: [:create, :destroy]

        resources :tax_returns, only: [] do
          patch "update_certification", to: "tax_returns/certifications#update", on: :member
        end
        resources :organizations, only: [:index, :create, :new, :show, :edit, :update] do
          patch "/suspend_all", to: "organizations#suspend_all", on: :member, as: :suspend_all
          patch "/activate_all", to: "organizations#activate_all", on: :member, as: :activate_all
        end
        resources :sites, only: [:new, :create, :edit, :update]
        resources :anonymized_intake_csv_extracts, only: [:index, :show], path: "/csv-extracts", as: :csv_extracts
        resources :users, only: [:index, :edit, :update, :destroy] do
          patch "/unlock", to: "users#unlock", on: :member, as: :unlock
          patch "/suspend", to: "users#suspend", on: :member, as: :suspend
          patch "/unsuspend", to: "users#unsuspend", on: :member, as: :unsuspend
          get "/edit_role", to: "users#edit_role", on: :member, as: :edit_role
          patch "/update_role", to: "users#update_role", on: :member, as: :update_role
        end
        resources :user_notifications, only: [:index], path: "/notifications" do
          post "/mark-all-read", to: 'user_notifications#mark_all_notifications_read', as: :mark_all_read, on: :collection
        end
        get "/profile" => "users#profile", as: :user_profile
      end

      put "hub/users/:user_id/resend", to: "hub/users#resend_invitation", as: :user_profile_resend_invitation

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
    post "/outgoing_email_status", to: "mailgun_webhooks#update_outgoing_email_status", as: :outgoing_email_status

    resources :ajax_mixpanel_events, only: [:create]

    mount ActionCable.server => '/cable'
  end

  constraints(Routes::CtcDomain.new) do
    get "/" => "ctc_pages#home"

    scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
      get "/" => "ctc_pages#home"
    end
  end
end
