Rails.application.routes.draw do
  active_state_codes = StateFile::StateInformationService.active_state_codes

  active_state_codes.each do |code|
    devise_for "state_file_#{code}_intakes"
  end
  devise_for :clients

  devise_scope :client do
    delete 'clients/sign_out', to: 'devise/sessions#destroy', as: :destroy_client_session
  end

  def login_routes
    resources :client_logins, path: "login", only: [:new, :create, :edit, :update], path_names: { new: '', edit: '' } do
      get "locked", to: "client_logins#account_locked", as: :account_locked, on: :collection
      put "check-verification-code", to: "client_logins#check_verification_code", as: :check_verification_code, on: :collection
    end
  end

  def scoped_navigation_routes(context, navigation)
    # must not be inside a `namespace :ctc` etc because the controllers' `.controller_path` includes the full namespace,
    # but `namespace :ctc` would look for Ctc::Ctc::XyzController.
    scope context, as: context do
      navigation.controllers.uniq.each do |controller_class|
        next if controller_class.navigation_actions.length > 1

        { get: :edit, put: :update }.each do |method, action|
          resource_name = controller_class.respond_to?(:resource_name) ? controller_class.resource_name : nil
          if resource_name
            resources resource_name, only: [] do
              member do
                match(
                  "/#{controller_class.to_param}",
                  action: action,
                  controller: controller_class.controller_path,
                  via: method
                )
              end
            end
          else
            match(
              "/#{controller_class.to_param}",
              action: action,
              controller: controller_class.controller_path,
              via: method,
            )
          end
        end
      end
      yield if block_given?
    end
  end

  get '/healthcheck' => 'public_pages#healthcheck'
  resources :session_toggles, only: [:index, :create]

  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
    get "/500", to: "public_pages#internal_server_error"
    get "/422", to: "public_pages#internal_server_error"
    get "/404", to: "public_pages#page_not_found"
  end

  constraints(Routes::GyrDomain.new) do
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

      namespace :questions do
        resources :dependents, only: [:index, :new, :create, :edit, :update, :destroy]
      end

      resources :questions, controller: :questions do
        collection do
          Navigation::GyrQuestionNavigation.controllers.uniq.each do |controller_class|
            next if controller_class.navigation_actions != [:edit]

            { get: :edit, put: :update }.each do |method, action|
              match "/#{controller_class.to_param}",
                    action: action,
                    controller: controller_class.controller_path,
                    via: method
            end
          end
        end
      end

      resources :documents do
        collection do
          Navigation::DocumentNavigation.controllers.uniq.each do |controller_class|
            { get: :edit, put: :update, delete: :destroy }.each do |method, action|
              match "/#{controller_class.to_param}",
                    action: action,
                    controller: controller_class.controller_path,
                    via: method
            end
          end
        end
      end

      namespace :documents do
        get "/doc-help/:doc_type", to: "documents_help#show", as: :help
        post '/send-reminder', to: 'documents_help#send_reminder', as: :send_reminder
        post '/request-doc-help', to: 'documents_help#request_doc_help', as: :request_doc_help
      end

      resources :signups, only: [:new, :create], path: "sign-up", path_names: { new: '' } do
        get "/confirmation", to: "signups#confirmation", on: :collection
      end

      Navigation::DiyNavigation.controllers.uniq.each do |controller_class|
        match "/#{controller_class.controller_path}",
              action: :edit,
              controller: controller_class.controller_path,
              via: :get
        if controller_class.method_defined?(:update)
          match "/#{controller_class.controller_path}",
                action: :update,
                controller: controller_class.controller_path,
                via: :put
        end
      end
      get "/diy", to: redirect { Diy::FileYourselfController.to_path_helper }
      get "/diy/email", to: redirect { Diy::FileYourselfController.to_path_helper }
      get "/diy/click_fsa_link", to: "diy/continue_to_fsa#click_fsa_link", as: :click_fsa_link

      unless Rails.env.production?
        get "/pending", to: "public_pages#pending"
      end
      get "/other-options", to: "public_pages#other_options"
      get "/maybe-ineligible", to: "public_pages#maybe_ineligible"
      get "/maintenance", to: "public_pages#maintenance"
      get "/volunteers", to: "public_pages#volunteers"
      get "/privacy", to: "public_pages#privacy_policy"
      get "/about-us", to: "public_pages#about_us"
      get "/tax-questions", to: "public_pages#tax_questions"
      get "/faq", to: "faq#index"
      get "/faq/:section_key", to: "faq#section_index", as: :faq_section
      get "/faq/:section_key/:question_key", to: "faq#show", as: :faq_question
      put "/faq/:section_key/:question_key", to: "faq#answer_survey"
      get "/sms-terms", to: "public_pages#sms_terms"
      get "/stimulus", to: "public_pages#stimulus"
      get "/full-service", to: "public_pages#full_service"
      get "/consent-to-use", to: "consent_pages#consent_to_use"
      get "/consent-to-disclose", to: "consent_pages#consent_to_disclose"
      get "/relational-efin", to: "consent_pages#relational_efin"
      get "/global-carryforward", to: "consent_pages#global_carryforward"
      get "/unsubscribe_from_emails", to: "notifications_settings#unsubscribe_from_emails", as: :unsubscribe_from_emails
      post "/subscribe_to_emails", to: "notifications_settings#subscribe_to_emails", as: :subscribe_to_emails

      namespace :portal do
        root "portal#home"

        # Add redirect for pre-March-2021-style login token links; safe to delete in April 2021
        get "/account/:id", to: redirect { |_, request| "/#{request.params[:locale] || "en"}/portal/login/#{request.params[:id]}" }
        get "/closed", to: 'closed_logins#show', as: :closed_login

        login_routes

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
        get '/still-need-help/upload-documents', to: "still_needs_helps#upload_documents", as: :still_needs_help_upload_documents
        put '/still-need-help/no-more-documents', to: "still_needs_helps#no_more_documents", as: :still_needs_help_no_more_documents
        get '/still-need-help/thank-you', to: "still_needs_helps#no_longer_needs_help", as: :still_needs_help_no_longer_needs_help
        put '/still-need-help/thank-you', to: "still_needs_helps#experience_survey", as: :still_needs_help_experience_survey
        resources :messages, only: [:new, :create]
        resources :documents, only: [:show]
        resources :upload_documents, only: [:destroy]
        match 'upload-documents/overview', to: 'upload_documents#index', via: :get, as: :overview_documents
        match 'upload-documents', to: 'upload_documents#edit', via: :get, as: :edit_upload_documents
        match 'upload-documents', to: 'upload_documents#update', via: :put
      end

      # Hub Admin routes (Case Management)
      namespace :hub do
        # root "assigned_clients#index"

        # Feature flags are admin access only
        constraints CanAccessFlipperUI do
          mount Flipper::UI.app(Flipper) => '/flipper'
        end

        # Delayed job web UI is admin access only
        constraints CanAccessDelayedJobWeb do
          mount DelayedJobWeb => "/delayed_job"
        end

        resources :metrics, only: [:index]
        resources :data_migrations, only: [:index] do
          collection do
            put :migrate
          end
        end
        resources :intentional_log, only: [:index]
        resources :tax_returns, only: [:edit, :update, :show]

        resources :fraud_indicators, path: "fraud-indicators" do
          collection do
            resources :risky_domains, controller: 'fraud_indicators/risky_domains', path: "risky-domains"
            resources :safe_domains, controller: 'fraud_indicators/safe_domains', path: "safe-domains"
            resources :timezones, controller: 'fraud_indicators/timezones', path: "timezones"
            resources :routing_numbers, controller: 'fraud_indicators/routing_numbers', path: "routing-numbers"
          end
        end

        namespace :admin do
          resources :experiments, only: [:index, :show, :edit, :update]
          resources :experiment_participants, only: [:edit, :update]
        end

        resources :efile_errors, path: "errors", except: [:create, :new, :destroy] do
          patch "/reprocess", to: "efile_errors#reprocess", on: :member, as: :reprocess
        end

        resources :faq_categories, path: "faq" do
          resources :faq_items
        end

        namespace :state_file, path: "state-file" do
          resources :efile_submissions, only: [:index, :show]  do
            get "show_xml", to: "efile_submissions#show_xml"
            get "show_df_xml", to: "efile_submissions#show_df_xml"
            get "show_pdf", to: "efile_submissions#show_pdf"
            get "/state-counts", to: 'efile_submissions#state_counts', on: :collection, as: :state_counts
            patch '/transition-to/:to_state', to: 'efile_submissions#transition_to', on: :member, as: :transition_to
          end

          resources :efile_errors, path: "errors", except: [:create, :new, :destroy] do
            patch "/reprocess", to: "efile_errors#reprocess", on: :member, as: :reprocess
          end

          resources :faq_categories, path: "faq" do
            resources :faq_items
          end
          resources :automated_messages, only: [:index]
        end

        resources :assigned_clients, path: "assigned", only: [:index]
        resources :state_routings, only: [:index, :edit, :update], param: :state do
          put "/add-organizations", to: "state_routings#add_organizations", on: :member, as: :add_organizations
        end
        resources :automated_messages, only: [:index]
        resources :portal_states, only: [:index]
        resources :bulk_message_csvs, only: [:index, :create]
        resources :signup_selections, only: [:index, :create]
        resources :bulk_signup_messages, only: [:new, :create]
        resources :verification_attempts, path: "verifications", only: [:index, :show, :update]

        resources :clients do
          get "/organization", to: "clients/organizations#edit", on: :member, as: :edit_organization
          patch "/organization", to: "clients/organizations#update", on: :member, as: :organization
          patch "/unlock", to: "clients#unlock", on: :member, as: :unlock
          get "/edit_13614c_form_page1", to: "clients#edit_13614c_form_page1", on: :member, as: :edit_13614c_form_page1
          get "/edit_13614c_form_page2", to: "clients#edit_13614c_form_page2", on: :member
          get "/edit_13614c_form_page3", to: "clients#edit_13614c_form_page3", on: :member
          get "/edit_13614c_form_page4", to: "clients#edit_13614c_form_page4", on: :member
          get "/edit_13614c_form_page5", to: "clients#edit_13614c_form_page5", on: :member
          put "/edit_13614c_form_page1", to: "clients#update_13614c_form_page1", on: :member
          put "/edit_13614c_form_page2", to: "clients#update_13614c_form_page2", on: :member
          put "/edit_13614c_form_page3", to: "clients#update_13614c_form_page3", on: :member
          put "/edit_13614c_form_page4", to: "clients#update_13614c_form_page4", on: :member
          put "/edit_13614c_form_page5", to: "clients#update_13614c_form_page5", on: :member
          get "/cancel_13614c", to: "clients#cancel_13614c", on: :member
          get "/bai", to: "clients/bank_accounts#show", on: :member, as: :show_bank_account
          get "/hide-bai", to: "clients/bank_accounts#hide", on: :member, as: :hide_bank_account
          get "/show_secret", to: "clients/secrets#show", on: :member
          get "/hide_secret", to: "clients/secrets#hide", on: :member
          get "/finder", to: "clients#resource_to_client_redirect", on: :member, as: :client_finder
          resources :documents do
            get "/archived", to: "documents#archived", on: :collection, as: :archived
            get "/confirm", to: "documents#confirm", on: :member, as: :confirm
          end
          resources :notes, only: [:create, :index]
          resources :messages, only: [:index]
          resources :analytics, only: [:index]
          post '/no_response_needed', to: 'messages#no_response_needed', as: :no_response_needed
          get "/efile", to: "efile_submissions#show", on: :member, as: :efile
          get "/security", to: "security#show", on: :member, as: :security
          resources :outgoing_text_messages, only: [:create]
          resources :outgoing_emails, only: [:create]
          resources :outbound_calls, only: [:new, :create, :show, :update]
          resources :tax_returns, only: [:new, :create]
          member do
            patch "flag"
            patch "toggle_field"
            get "edit_take_action"
            post "update_take_action"
          end
        end
        resources :ctc_clients, only: [:edit, :update]

        resources :dashboard, only: [:index] do
          get "/:type/:id", to: "dashboard#show", on: :collection, as: :show
          get "/:type/:id/returns-by-status", to: "dashboard#returns_by_status", on: :collection, as: :returns_by_status
          get "/:type/:id/team-assignment", to: "dashboard#team_assignment", on: :collection, as: :team_assignment
        end

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
        resources :source_params, only: [:create, :update, :destroy]

        resources :tax_returns, only: [] do
          patch "update_certification", to: "tax_returns/certifications#update", on: :member
        end
        resources :coalitions, only: [:new, :create, :edit, :update]
        resources :organizations, only: [:index, :create, :new, :show, :edit, :update] do
          patch "/suspend_all", to: "organizations#suspend_all", on: :member, as: :suspend_all
          patch "/activate_all", to: "organizations#activate_all", on: :member, as: :activate_all
        end
        resources :sites, only: [:new, :create, :edit, :update]
        resources :anonymized_intake_csv_extracts, only: [:index, :show], path: "/csv-extracts", as: :csv_extracts
        scope :users, module: :users do
          resource :strong_passwords, only: [:edit, :update]
        end
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
        resources :tools, only: [:index]
        resources :admin_tools, only: [:index]
        resources :state_file_admin_tools, only: [:index]
        resources :ctc_intake_capacity, only: [:index, :create]
        resources :admin_toggles, only: [:index, :create]
        get "/profile" => "users#profile", as: :user_profile
        resources :trusted_proxies, only: [:index]
      end

      put "hub/users/:user_id/resend", to: "hub/users#resend_invitation", as: :user_profile_resend_invitation

      devise_for :users, path: "hub", skip: :omniauth_callbacks, controllers: {
        sessions: "users/sessions",
        invitations: "users/invitations"
      }

      get "hub/users/invitations" => "invitations#index", as: :invitations
      put "hub/users/invitations/:user_id/resend", to: "invitations#resend_invitation", as: :user_resend_invitation
      ### END Hub Admin routes (Case Management)

      unless Rails.env.production?
        resources :flows, only: [:index, :show] do
          post :generate, on: :collection
        end
        resources :icons, only: [:index]
      end

      # Any other top level slash just goes to home as a source parameter
      get "/:source" => "public_pages#home", constraints: { source: /[0-9a-zA-Z_-]{1,100}/ }, as: :root_with_source
    end
    # Routes outside of the locale scope are not internationalized

    # Twilio webhook routes
    post "/outgoing_text_messages/:id", to: "twilio_webhooks#update_outgoing_text_message", as: :outgoing_text_message
    post "/webhooks/twilio/update_status/:id", to: "twilio_webhooks#update_status", as: :twilio_update_status
    post "/outbound_calls/:id", to: "twilio_webhooks#update_outbound_call", as: :outbound_calls_webhook
    post "/incoming_text_messages", to: "twilio_webhooks#create_incoming_text_message", as: :incoming_text_messages
    post "/outbound_calls/connect/:id", to: "twilio_webhooks#outbound_call_connect", as: :twilio_connect_to_client, defaults: { format: "xml" }
    # Mailgun webhook routes
    post "/incoming_emails", to: "mailgun_webhooks#create_incoming_email", as: :incoming_emails
    post "/outgoing_email_status", to: "mailgun_webhooks#update_outgoing_email_status", as: :outgoing_email_status
    # OAuth login callback routes
    devise_for :users, path: "hub", only: :omniauth_callbacks, skip: [:session, :invitation], controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
    # AWS IP ranges update trigger
    post "/update_aws_ip_ranges", to: "aws_ip_ranges_webhooks#update_aws_ip_ranges", as: :update_aws_ip_ranges

    resources :ajax_mixpanel_events, only: [:create]

    mount ActionCable.server => '/cable'
    get '/.well-known/pki-validation/:id', to: 'public_pages#pki_validation'
  end

  constraints(Routes::CtcDomain.new) do
    scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
      root to: "ctc/ctc_pages#home", as: :ctc_home
    end
  end

  devise_for :state_file_archived_intake_requests

  constraints(Routes::StateFileDomain.new) do
    scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
      namespace :state_file do
        namespace :archived_intakes do
          get 'email_address/edit', to: 'email_address#edit', as: 'edit_email_address'
          patch 'email_address', to: 'email_address#update'
          get 'verification_code/edit', to: 'verification_code#edit', as: 'edit_verification_code'
          patch 'verification_code', to: 'verification_code#update'
          get 'mailing_address_validation/edit', to: 'mailing_address_validation#edit', as: 'edit_mailing_address_validation'
          patch 'mailing_address_validation', to: 'mailing_address_validation#update'
          get 'verification_error', to: "/state_file/state_file_pages#archived_intakes_verification_error"
          get 'identification_number/edit', to: 'identification_number#edit', as: 'edit_identification_number'
          patch 'identification_number', to: 'identification_number#update'
          post 'pdfs/log_and_redirect', to: 'pdfs#log_and_redirect'
          resources :pdfs, only: [:index]
        end
        namespace :questions do
          get "show_xml", to: "confirmation#show_xml"
          get "explain_calculations", to: "confirmation#explain_calculations"
        end
      end

      resources :submission_pdfs, only: [:show], module: 'state_file/questions', path: 'questions/submission_pdfs'
      resources :federal_dependents, only: [:index, :new, :create, :edit, :update, :destroy], module: 'state_file/questions', path: 'questions/federal_dependents'
      resources :unemployment, only: [:index, :new, :create, :edit, :update, :destroy], module: 'state_file/questions', path: 'questions/unemployment'
      resources :retirement_income, only: [:edit, :update], module: 'state_file/questions', path: 'questions/retirement_income'
      resources :az_qualifying_organization_contributions,
        only: [
          :index, :new, :create, :edit,
          :update, :destroy
        ],
        module: 'state_file/questions',
        path: 'questions/az-qualifying-organization-contributions'

      resources :az_public_school_contributions, only: [:index, :new, :create, :edit, :update, :destroy], module: 'state_file/questions', path: 'questions/az-public-school-contributions'
      get "/data-import-failed", to: "state_file/state_file_pages#data_import_failed"
      get "/initiate-data-transfer", to: "state_file/questions/initiate_data_transfer#initiate_data_transfer"

      get '/az/questions/return-status', to: redirect('/')
      get '/az/questions/submission-confirmation', to: redirect('/')

      resources :intake_logins, only: [:new, :create, :edit, :update], module: "state_file", path: "login" do
        put "check-verification-code", to: "intake_logins#check_verification_code", as: :check_verification_code, on: :collection
        get "locked", to: "intake_logins#account_locked", as: :account_locked, on: :collection
      end

      get "login-options", to: "state_file/state_file_pages#login_options"

      match("/questions/pending-federal-return", action: :edit, controller: "state_file/questions/pending_federal_return", via: :get)
      match("/questions/pending_federal_return", action: :edit, controller: "state_file/questions/pending_federal_return", via: :get)
      resources :w2, only: [:edit, :update], module: 'state_file/questions', path: 'questions/w2'

      active_state_codes.each do |code|
        navigation_class = StateFile::StateInformationService.navigation_class(code)
        scoped_navigation_routes(:questions, navigation_class)
      end

      match("/code-verified", action: :edit, controller: "state_file/questions/code_verified", via: :get)
      match("/code-verified", action: :update, controller: "state_file/questions/code_verified", via: :put)

      # constraint on us state is like /az|ny|us/i
      scope ':us_state', constraints: { us_state: Regexp.new((active_state_codes + ["us"]).join("|"), Regexp::IGNORECASE) } do
        get "/faq", to: "state_file/faq#index", as: :state_faq
        get "/faq/:section_key", to: "state_file/faq#show", as: :state_faq_section
      end

      # constraint on us state is like /az|ny/i
      scope ':us_state', constraints: { us_state: Regexp.new(active_state_codes.join("|"), Regexp::IGNORECASE) } do
        get "/landing-page", to: "state_file/landing_page#edit", as: :state_landing_page
        put "/landing-page", to: "state_file/landing_page#update"
      end

      unless Rails.env.production?
        resources :flows, only: [:index, :show] do
          post :generate, on: :collection
        end
      end
    end

    namespace :state_file, path: "/" do
      scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
        root to: "state_file_pages#about_page"
        get "/fake_direct_file_transfer_page", to: "state_file_pages#fake_direct_file_transfer_page"
        get "/coming-soon", to: "state_file_pages#coming_soon"
        post "/clear_session", to: 'state_file_pages#clear_session'
        get "/privacy-policy", to: "state_file_pages#privacy_policy"
        get "/sms-terms", to: "state_file_pages#sms_terms"
        get "/unsubscribe_from_emails", to: "notifications_settings#unsubscribe_from_emails", as: :unsubscribe_from_emails
        post "/subscribe_to_emails", to: "notifications_settings#subscribe_to_emails", as: :subscribe_to_emails
        get "/id_file_with_another_service", to: "questions/id_ineligible_retirement_and_pension_income#file_with_another_service"
        get "/continue_filing", to: "questions/id_ineligible_retirement_and_pension_income#continue_filing"
      end
    end
  end

  get '*unmatched_route', to: 'public_pages#page_not_found', constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage'
  }
end
