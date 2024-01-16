Rails.application.routes.draw do
  devise_for :state_file_az_intakes
  devise_for :state_file_ny_intakes
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
        resources :efile_submissions, path: "efile", only: [:index, :show] do
          patch '/resubmit', to: 'efile_submissions#resubmit', on: :member, as: :resubmit
          patch '/failed', to: 'efile_submissions#failed', on: :member, as: :failed
          patch '/cancel', to: 'efile_submissions#cancel', on: :member, as: :cancel
          patch '/investigate', to: 'efile_submissions#investigate', on: :member, as: :investigate
          patch '/wait', to: 'efile_submissions#wait', on: :member, as: :wait
          get '/download', to: 'efile_submissions#download', on: :member, as: :download
          get '/state-counts', to: 'efile_submissions#state_counts', on: :collection, as: :state_counts
        end

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
          end
          resources :faq_categories, path: "faq" do
            resources :faq_items
          end
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
          put "/edit_13614c_form_page1", to: "clients#update_13614c_form_page1", on: :member
          put "/edit_13614c_form_page2", to: "clients#update_13614c_form_page2", on: :member
          put "/edit_13614c_form_page3", to: "clients#update_13614c_form_page3", on: :member
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
        resources :ctc_intake_capacity, only: [:index, :create]
        resources :admin_toggles, only: [:index, :create]
        get "/profile" => "users#profile", as: :user_profile
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

    resources :ajax_mixpanel_events, only: [:create]

    mount ActionCable.server => '/cable'
    get '/.well-known/pki-validation/:id', to: 'public_pages#pki_validation'
  end

  constraints(Routes::CtcDomain.new) do
    scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
      scoped_navigation_routes(:questions, Navigation::CtcQuestionNavigation)

      # offboarding pages
      get "/questions/use-gyr", to: "ctc/questions/use_gyr#edit", as: :questions_use_gyr
      get "/questions/returning-client", to: "ctc/questions/returning_client#edit", as: :questions_returning_client
      get "/already-filed", to: "ctc/offboarding/already_filed#show", as: :offboarding_already_filed
      get "/actc-without-dependents", to: "ctc/offboarding/actc_without_dependents#show", as: :offboarding_actc_without_dependents
      get "/actc-without-dependents-use-gyr", to: "ctc/offboarding/actc_without_dependents#file_with_gyr", as: :offboarding_actc_without_dependents_file_with_gyr
      get "/questions/at-capacity", to: "ctc/questions/at_capacity#edit", as: :questions_at_capacity
      get "/questions/not-filing", to: "ctc/questions/not_filing#edit", as: :questions_not_filing

      # remove-spouse should not be included in default navigation flow
      get "/questions/remove-spouse", to: "ctc/questions/remove_spouse#edit", as: :questions_remove_spouse
      put "/questions/remove-spouse", to: "ctc/questions/remove_spouse#update"

      # remove-dependent should not be included in default navigation flow
      get "/questions/dependents/:id/remove-dependent", to: "ctc/questions/dependents/remove_dependent#edit", as: :questions_remove_dependent
      put "/questions/dependents/:id/remove-dependent", to: "ctc/questions/dependents/remove_dependent#update"

      put "/questions/w2s/add-w2-later", to: "ctc/questions/w2s#add_w2_later"
      delete "/questions/confirm-w2s", to: "ctc/questions/confirm_w2s#destroy"

      patch '/questions/confirm_payment', to: 'ctc/questions/confirm_payment#do_not_file', as: :questions_do_not_file

      unless Rails.env.production?
        resources :flows, only: [:index, :show] do
          post :generate, on: :collection
        end
      end
    end

    namespace :ctc, path: "/" do
      root to: "ctc_pages#redirect_locale_home", as: :ctc_redirected_root

      scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
        root to: "ctc_pages#home"

        resources :signups, only: [:new, :create], path: "sign-up", path_names: { new: '' } do
          get "/confirmation", to: "signups#confirmation", on: :collection
        end

        get "/completed-intake", to: "ctc_pages#completed"
        get "/help", to: "ctc_pages#help"
        get "/stimulus", to: "ctc_pages#stimulus"
        get "/stimulus-navigator", to: "ctc_pages#stimulus_navigator"
        get "/privacy", to: "ctc_pages#privacy_policy"
        get "/navigators", to: "ctc_pages#navigators"
        get "/puertorico", to: "ctc_pages#puerto_rico"
        get "/puerto-rico-overview", to: "ctc_pages#puerto_rico_overview"

        scope "common-questions" do
          get "/what-will-i-need-to-submit", to: "ctc_pages#what_will_i_need_to_submit"
          get "/check-payment-status", to: "ctc_pages#check_payment_status"
          get "/what-will-happen-and-when", to: "ctc_pages#what_will_happen_and_when"
          get "/how-do-i-know-what-i-received-for-the-stimulus", to: "ctc_pages#how_do_i_know_what_i_received_for_the_stimulus"
          get "/will-i-ever-have-to-pay-this-money-back", to: "ctc_pages#will_i_ever_have_to_pay_this_money_back"
          get "/parents-with-shared-custody", to: "ctc_pages#parents_with_shared_custody"
          get "/no-income-or-income-from-benefits-programs", to: "ctc_pages#no_income_or_income_from_benefits_programs"
          get "/are-daca-recipients-eligible", to: "ctc_pages#are_daca_recipients_eligible"
          get "/will-it-affect-my-immigration-status", to: "ctc_pages#will_it_affect_my_immigration_status"
          get "/how-do-i-get-an-itin", to: "ctc_pages#how_do_i_get_an_itin"
        end

        namespace :update do
          get 'primary-filer', to: "primary_filer#edit"
          put 'primary-filer', to: "primary_filer#update"

          get 'mailing-address', to: "mailing_address#edit"
          put 'mailing-address', to: "mailing_address#update"

          get 'spouse', to: "spouse#edit"
          put 'spouse', to: "spouse#update"

          get 'prior-tax-year-agi', to: "prior_tax_year_agi#edit"
          put 'prior-tax-year-agi', to: "prior_tax_year_agi#update"

          get 'spouse-prior-tax-year-agi', to: "spouse_prior_tax_year_agi#edit"
          put 'spouse-prior-tax-year-agi', to: "spouse_prior_tax_year_agi#update"

          resources :dependents, only: [:edit, :update, :destroy] do
            get :confirm_remove, on: :member
          end
        end
        namespace :portal do
          root "portal#home"
          login_routes

          get 'edit_info', to: "portal#edit_info"
          put 'resubmit', to: "portal#resubmit"

          get 'primary_filer', to: "primary_filer#edit"
          put 'primary_filer', to: "primary_filer#update"

          get 'mailing_address', to: "mailing_address#edit"
          put 'mailing_address', to: "mailing_address#update"

          get 'spouse', to: "spouse#edit"
          put 'spouse', to: "spouse#update"

          get 'refund-payment', to: "refund_payment#edit"
          put 'refund-payment', to: "refund_payment#update"

          get 'bank-account', to: "bank_account#edit"
          put 'bank-account', to: "bank_account#update"

          get 'prior-tax-year-agi', to: "prior_tax_year_agi#edit"
          put 'prior-tax-year-agi', to: "prior_tax_year_agi#update"

          get 'spouse-prior-tax-year-agi', to: "spouse_prior_tax_year_agi#edit"
          put 'spouse-prior-tax-year-agi', to: "spouse_prior_tax_year_agi#update"

          resources :w2s do
            get 'w2s-employee-info', on: :member, to: "w2s/employee_info#edit"
            put 'w2s-employee-info', on: :member, to: "w2s/employee_info#update"
            get 'w2s-wages-info', on: :member, to: "w2s/wages_info#edit"
            put 'w2s-wages-info', on: :member, to: "w2s/wages_info#update"
            get 'w2s-employer-info', on: :member, to: "w2s/employer_info#edit"
            put 'w2s-employer-info', on: :member, to: "w2s/employer_info#update"
            get 'w2s-misc-info', on: :member, to: "w2s/misc_info#edit"
            put 'w2s-misc-info', on: :member, to: "w2s/misc_info#update"
          end

          get "verification", to: "verification_attempts#edit", as: "verification_attempt"
          patch "verification", to: "verification_attempts#update", as: "update_verification_attempt"
          delete "verification-photo/:id", to: "verification_attempts#destroy", as: "destroy_verification_attempt_photo"
          get "paper-file", to: 'verification_attempts#paper_file', as: "verification_attempt_paper_file"

          resources :dependents, only: [:edit, :update, :destroy] do
            get :confirm_remove, on: :member
            get 'dependent-removal-summary', to: "pages#dependent_removal_summary", on: :collection
          end
          resources :messages, only: [:new, :create]
          resources :documents, only: [:show]
          resources :submission_pdfs, only: [:show] do
            member do
              get ':filename', to: 'submission_pdfs#show', as: "filename"
            end
          end
          resources :upload_documents, only: [:destroy]
          match 'upload-documents', to: 'upload_documents#edit', via: :get, as: :edit_upload_documents
          match 'upload-documents', to: 'upload_documents#update', via: :put
        end

        # Any other top level slash just goes to home as a source parameter
        get "/:source" => "ctc_pages#home", constraints: { source: /[0-9a-zA-Z_-]{1,100}/ }
      end
    end

    resources :ajax_mixpanel_events, only: [:create]

    get '/.well-known/pki-validation/:id', to: 'public_pages#pki_validation'
  end

  constraints(Routes::StateFileDomain.new) do
    scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
      namespace :state_file do
        namespace :questions do
          get "show_xml", to: "confirmation#show_xml"
          get "explain_calculations", to: "confirmation#explain_calculations"
          get "pending_federal_return", to: "pending_federal_return#edit"
          get "canceled_data_transfer", to: "canceled_data_transfer#edit"
          get "other_filing_options", to: "other_filing_options#edit"
        end
      end

      scope ':us_state', constraints: { us_state: /az|ny/ } do
        resources :submission_pdfs, only: [:show], module: 'state_file/questions', path: 'questions/submission_pdfs'
        resources :federal_dependents, only: [:index, :new, :create, :edit, :update, :destroy], module: 'state_file/questions', path: 'questions/federal_dependents'
        resources :unemployment, only: [:index, :new, :create, :edit, :update, :destroy], module: 'state_file/questions', path: 'questions/unemployment'
        resources :intake_logins, only: [:new, :create, :edit, :update], module: "state_file", path: "login" do
          put "check-verification-code", to: "intake_logins#check_verification_code", as: :check_verification_code, on: :collection
        end
        get "payment_voucher", to: "state_file/payment_voucher#show"
        get "login-options", to: "state_file/state_file_pages#login_options"
        get "/faq", to: "state_file/faq#index", as: :state_faq
        get "/faq/:section_key", to: "state_file/faq#show", as: :state_faq_section
      end

      scope ':us_state', as: 'az', constraints: { us_state: :az } do
        scoped_navigation_routes(:questions, Navigation::StateFileAzQuestionNavigation)
      end

      scope ':us_state', as: 'ny', constraints: { us_state: :ny } do
        scoped_navigation_routes(:questions, Navigation::StateFileNyQuestionNavigation)
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
        post "/clear_session", to: 'state_file_pages#clear_session'
      end
    end
  end

  get '*unmatched_route', to: 'public_pages#page_not_found', constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage'
  }
end
