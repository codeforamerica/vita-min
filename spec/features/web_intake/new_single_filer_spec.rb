require "rails_helper"

RSpec.feature "Web Intake Single Filer", :flow_explorer_screenshot, active_job: true do
  include MockTwilio

  let!(:vita_partner) { create :organization, name: "Virginia Partner" }
  let!(:vita_partner_zip_code) { create :vita_partner_zip_code, zip_code: "20121", vita_partner: vita_partner }

  before do
    allow(Airtable::Organization)
      .to receive(:language_offerings)
            .and_return({
                          "Test Organization" => %w[Spanish French],
                        })
  end

  def intake_up_to_documents
    answer_gyr_triage_questions(choices: :defaults)

    # creates intake and triage
    intake = Intake.last

    page_change_block do
      expect(intake.triage).to eq(Triage.last)
    end

    page_change_block do
      expect(page).to have_selector("h1", text: I18n.t('questions.triage_gyr_diy.edit.title'))
      click_on I18n.t('questions.triage.gyr_tile.choose_gyr')
    end

    page_change_block do
      expect(page).to have_selector("h1", text: I18n.t('questions.triage_gyr_ids.edit.title'))
      click_on I18n.t('questions.triage_gyr_ids.edit.yes_i_have_id')
    end

    page_change_block do
      # Non-production environment warning
      expect(page).to have_text I18n.t('views.questions.environment_warning.title')
      click_on I18n.t('general.continue_example')
    end

    intake_after_triage_up_to_documents(intake)
  end

  def intake_after_triage_up_to_documents(intake)
    page_change_block do
      # Interview time preferences
      expect(intake.reload.current_step).to end_with("/questions/interview-scheduling")
      fill_in "Do you have any time preferences for your interview phone call?", with: "Wednesday or Tuesday nights"
      expect(page).to have_select("What is your preferred language for the review?", selected: "English")
      select("Spanish", from: "What is your preferred language for the review?")
      click_on "Continue"
    end

    page_change_block do
      select "Social Security Number (SSN)", from: "Identification Type"
      fill_in I18n.t("attributes.primary_ssn"), with: "123-45-6789"
      fill_in I18n.t("attributes.confirm_primary_ssn"), with: "123-45-6789"
      click_on "Continue"
    end

    current_tax_year = MultiTenantService.new(:gyr).current_tax_year
    page_change_block do
      # Ask about backtaxes
      page_change_check(I18n.t("views.questions.backtaxes.title"))
      expect(intake.reload.current_step).to end_with("/questions/backtaxes")
      expect(page).to have_selector("h1", text: I18n.t("views.questions.backtaxes.title"))
      check "#{current_tax_year}"
      check "#{current_tax_year - 2}"
      click_on "Continue"
    end

    page_change_block(0.5) do
      # Start with current year
      expect(page).to have_selector("h1", text: I18n.t("views.questions.start_with_current_year.title", year: current_tax_year))
      click_on "Continue"
    end

    page_change_block do
      # Notification Preference
      page_change_check(I18n.t("views.questions.notification_preference.title"))
      expect(intake.reload.current_step).to end_with("/questions/notification-preference")
      expect(page).to have_text(I18n.t("views.questions.notification_preference.title"))
      check "Email Me"
      check "Text Me"
      click_on "Continue"
    end

    page_change_block do
      # Phone number can text
      expect(page).to have_text("Can we text the phone number you previously entered?")
      expect(page).to have_text("(828) 634-5533")
      click_on "No"
    end

    page_change_block do
      # Phone number
      expect(page).to have_selector("h1", text: "Please share your cell phone number.")
      fill_in "Cell phone number", with: "(415) 553-7865"
      fill_in "Confirm cell phone number", with: "+1415553-7865"
      click_on "Continue"
    end

    page_change_block do
      # Verify cell phone contact
      expect(page).to have_selector("h1", text: "Let's verify that contact info with a code!")
      perform_enqueued_jobs
      sms = FakeTwilioClient.messages.last
      code = sms.body.to_s.match(/\s(\d{6})[.]/)[1]
      fill_in "Enter 6 digit code", with: code
      click_on "Verify"
    end

    page_change_block do
      # Email
      expect(page).to have_selector("h1", text: "Please share your email address.")
      fill_in "Email address", with: "gary.gardengnome@example.green"
      fill_in "Confirm email address", with: "gary.gardengnome@example.green"
      click_on "Continue"
    end

    page_change_block do
      # Verify email contact
      expect(page).to have_selector("h1", text: "Let's verify that contact info with a code!")
      perform_enqueued_jobs
      mail = ActionMailer::Base.deliveries.last
      code = mail.html_part.body.to_s.match(%r{<strong> (\d{6})\.</strong>})[1]
      fill_in "Enter 6 digit code", with: code
      click_on "Verify"
    end

    page_change_block do
      # Consent form
      expect(page).to have_selector("h1", text: I18n.t('views.questions.consent.title'))
      fill_in I18n.t("views.questions.consent.primary_first_name"), with: "Gary"
      fill_in I18n.t("views.questions.consent.primary_last_name"), with: "Gnome"
      if intake.primary_birth_date.blank?
        select I18n.t("date.month_names")[3], from: "consent_form_birth_date_month"
        select "5", from: "consent_form_birth_date_day"
        select "1971", from: "consent_form_birth_date_year"
      end
      click_on I18n.t("views.questions.consent.cta")
    end

    page_change_block do
      # create tax returns only after client has consented
      expect(intake.client.tax_returns.pluck(:year).sort).to eq [MultiTenantService.new(:gyr).current_tax_year - 2, current_tax_year]

      # Optional consent form
      expect(page).to have_selector("h1", text: I18n.t('views.questions.optional_consent.title'))
      toggles = {
        strip_html_tags(I18n.t('views.questions.optional_consent.consent_to_use_html')).split(':').first => consent_to_use_path,
        strip_html_tags(I18n.t('views.questions.optional_consent.consent_to_disclose_html')).split(':').first => consent_to_disclose_path,
        strip_html_tags(I18n.t('views.questions.optional_consent.relational_efin_html')).split(':').first => relational_efin_path,
        strip_html_tags(I18n.t('views.questions.optional_consent.global_carryforward_html')).split(':').first => global_carryforward_path,
      }
      toggles.each do |toggle_text, link_path|
        expect(page).to have_checked_field(toggle_text)
        expect(page).to have_link(toggle_text, href: link_path)
      end
      uncheck toggles.keys.last
      click_on I18n.t('general.continue')
    end

    page_change_block do
      # Chat with us
      expect(page).to have_selector("h1", text: "Our team at Virginia Partner is here to help!")
      expect(page).to have_selector("p", text: "Virginia Partner handles tax returns from 20121 (Centreville, Virginia).")
      click_on "Continue"
    end

    page_change_block do
      # Primary filer personal information
      expect(page).to have_selector("h1", text: "Select any situations that were true for you in #{current_tax_year}")
      expect(track_progress).to eq(0)
      check I18n.t("general.none_of_the_above")
      click_on "Continue"
    end

    page_change_block do
      expect(page).to have_selector("h1", text: "Have you ever been issued an IP PIN because of identity theft?")
      expect { track_progress }.to change { @current_progress }.by_at_least(1)
      click_on "No"
    end

    page_change_block do
      # Marital status
      expect(page).to have_selector("h1", text: "Have you ever been legally married?")
      click_on "No"
    end

    page_change_block do
      # Claimed status
      expect(page).to have_css("h1", text: "Can anyone else claim you on their tax return?")
      click_on "No"
    end

    page_change_block do
      # Dependents
      page_change_check(I18n.t("views.questions.had_dependents.title", year: intake.most_recent_filing_year, count: intake.filer_count ))
      expect(intake.reload.current_step).to end_with("/questions/had-dependents")
      expect(page).to have_selector("h1", text: "Would you like to claim anyone for #{current_tax_year}?")
      click_on "No"
    end

    page_change_block do
      # Students
      expect(page).to have_selector("h1", text: I18n.t("views.questions.student.title", year: current_tax_year))
      click_on "Yes"
    end

    page_change_block do
      expect(page).to have_selector("h1", text: "In #{current_tax_year}, did you pay any student loan interest?")
      click_on "No"
    end

    page_change_block do
      # Income from working
      expect(intake.reload.current_step).to end_with("/questions/job-count")
      select "3 jobs", from: "In #{current_tax_year}, how many jobs did you have?"
      click_on "Continue"
    end

    page_change_block do
      expect(page).to have_selector("h1", text: "In #{current_tax_year}, did you live or work in any other states besides Virginia?")
      click_on "No"
    end

    page_change_block do
      expect(page).to have_selector("h1", text: "Tell us about your work in #{current_tax_year}")
      click_on "Continue"
    end

    page_change_block do
      # Income from benefits
      expect(page).to have_selector("h1", text: "In #{current_tax_year}, did you receive any disability benefits?")
      click_on "No"
    end

    page_change_block do
      # Investment income/loss
      expect(page).to have_selector("h1", text: "In #{current_tax_year}, did you have any income from interest or dividends?")
      click_on "No"
    end

    page_change_block do
      expect(page).to have_selector("h1", text: "In #{current_tax_year}, did you sell any stocks, bonds, or real estate?")
      click_on "Yes"
    end

    page_change_block do
      expect(page).to have_selector("h1", text: "In #{current_tax_year}, did you have any income from the sale of stocks, bonds, or real estate?")
      click_on "No"
    end

    page_change_block do
      expect(page).to have_selector("h1", text: "Did you report a loss from the sale of stocks, bonds, or real estate on your #{current_tax_year - 1} return?")
      click_on "Yes"
    end

    page_change_block do
      # Retirement income/contributions
      expect(intake.reload.current_step).to end_with("/questions/social-security-or-retirement")
      expect(page).to have_selector("h1", text: "In #{current_tax_year}, did you have Social Security income, retirement income, or retirement contributions?")
      click_on "No"
    end

    page_change_block do
      # Other income
      expect(page).to have_selector("h1", text: "In #{current_tax_year}, did you receive any other money?")
      click_on "Yes"
    end

    page_change_block do
      fill_in "What were the other types of income that you received?", with: "cash from gardening"
      click_on "Continue"
    end

    page_change_block do
      # Health insurance
      expect(page).to have_selector("h1", text: "Tell us about your health insurance in #{current_tax_year}.")
      check "I had Medicaid/Medicare"
      click_on "Continue"
    end

    page_change_block do
      # Itemizing
      expect(page).to have_selector("h1", text: "Would you like to itemize your deductions for #{current_tax_year}?")
      click_on "No"
    end

    page_change_block do
      expect(page).to have_selector("h1", text: "In #{current_tax_year}, did you pay any state, local, real estate, sales, or other taxes?")
      click_on "Yes"
    end

    page_change_block do
      expect(page).to have_selector("h1", text: "In #{current_tax_year}, did you receive a state or local income tax refund?")
      click_on "Yes"
    end

    page_change_block do
      # Related to home ownership
      expect(page).to have_selector("h1", text: "Have you ever owned a home?")
      click_on "Yes"
    end

    page_change_block do
      expect(page).to have_selector("h1", text: "In #{current_tax_year}, did you sell a home?")
      click_on "No"
    end

    page_change_block do
      expect(page).to have_selector("h1", text: "In #{current_tax_year}, did you pay any mortgage interest?")
      click_on "No"
    end

    page_change_block do
      # Miscellaneous
      expect(intake.reload.current_step).to end_with("/questions/disaster-loss")
      expect(page).to have_selector("h1", text: "In #{current_tax_year}, did you have a loss related to a declared Federal Disaster Area?")
      click_on "No"
    end

    page_change_block do
      expect(page).to have_selector("h1", text: "In #{current_tax_year}, did you have debt cancelled or forgiven by a lender?")
      click_on "No"
    end

    page_change_block do
      expect(page).to have_selector("h1", text: "In #{current_tax_year}, did you receive any letter or bill from the IRS?")
      click_on "Yes"
    end

    page_change_block do
      expect(page).to have_selector("h1", text: "Have you had the Earned Income Credit, Child Tax Credit, American Opportunity Credit, or Head of Household filing status disallowed in a prior year?")
      click_on "Yes"
    end

    page_change_block do
      expect(page).to have_selector("h1", text: "In #{current_tax_year}, did you make any estimated tax payments or apply your #{current_tax_year - 1} refund to your #{current_tax_year} taxes?")
      click_on "Yes"
    end

    page_change_block do
      expect(page).to have_selector("h1", text: "Did you report a business loss on your #{current_tax_year - 1} tax return?")
      click_on "No"
    end

    page_change_block do
      expect(page).to have_selector("h1", text: "Did you purchase a new vehicle in #{current_tax_year}?")
      click_on "Yes"
    end

    page_change_block do
      expect(page).to have_selector("h1", text: "In #{current_tax_year}, did you purchase energy efficient home items?")
      click_on "Yes"
    end

    page_change_block do
      # Payment info
      expect(page).to have_selector("h1", text: "If due a refund, how would like to receive it?")
      choose "Direct deposit (fastest)"
      expect(page).to have_text("If due a refund, are you interested in using these savings options?")
      check "Purchase United States Savings Bond"
      click_on "Continue"
    end

    page_change_block do
      # Pay from bank account?
      expect(page).to have_selector("h1", text: "If you owe a balance, how would you like to make a payment?")
      choose "Pay full amount through my bank account"
      click_on "Continue"
    end

    page_change_block do
      # Bank Details
      expect(page).to have_selector("h1", text: "Great, please provide your bank details below!")
      fill_in "Bank name", with: "First Savings Bank"
      fill_in "Routing number", with: "123456"
      fill_in "Account number", with: "987654321"
      choose "Checking"
      click_on "Continue"
    end

    page_change_block do
      # Contact information
      expect(intake.reload.current_step).to end_with("/questions/mailing-address")
      expect(page).to have_text("What is your mailing address?")
      expect(page).to have_select(I18n.t('views.questions.mailing_address.state'), selected: "Virginia")
      fill_in "Street address", with: "123 Main St."
      fill_in "City", with: "Anytown"
      select "California", from: "State"
      fill_in "ZIP code", with: "94612"
      click_on "Continue"
    end

    intake
  end

  scenario "new client filing single without dependents fills out intake up to documents flow" do
    answer_gyr_triage_questions(choices: :defaults)

    # creates intake and triage
    intake = Intake.last
    expect(intake.triage).to eq(Triage.last)

    expect(page).to have_selector("h1", text: I18n.t('questions.triage_gyr_diy.edit.title'))
    click_on I18n.t('questions.triage.gyr_tile.choose_gyr')

    expect(page).to have_selector("h1", text: I18n.t('questions.triage_gyr_ids.edit.title'))
    click_on I18n.t('questions.triage_gyr_ids.edit.yes_i_have_id')

    # Non-production environment warning
    expect(page).to have_text I18n.t('views.questions.environment_warning.title')
    click_on I18n.t('general.continue_example')

    intake_after_triage_up_to_documents(intake)
  end

  scenario "new client filing single without dependents fills out document flow" do
    intake = intake_up_to_documents

    # IRS guidance
    expect(page).to have_selector("h1", text: "First, we need to confirm your basic information.")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Attach a photo of your ID card")
    expect(page).to have_text(I18n.t('views.layouts.document_upload.accepted_file_types', accepted_types: FileTypeAllowedValidator.extensions(Document).to_sentence))
    upload_file("document_type_upload_form_upload", Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"))
    click_on "Continue"

    expect(intake.reload.current_step).to end_with("/documents/ssn-itins")
    expect(page).to have_selector("h1", text: I18n.t('views.documents.ssn_itins.title'))
    upload_file("document_type_upload_form_upload", Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"))
    click_on "Continue"

    # Documents: Intro
    expect(page).to have_selector("h1", text: I18n.t('views.documents.intro.title'))
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Share your employment documents")
    upload_file("document_type_upload_form_upload", Rails.root.join("spec", "fixtures", "files", "test-pattern.png"))

    expect(page).to have_content("test-pattern.png")
    expect(page).to have_link("Remove")

    upload_file("document_type_upload_form_upload", Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"))

    expect(page).to have_content("test-pattern.png")
    expect(page).to have_content("picture_id.jpg")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Please share any additional documents.")
    upload_file("document_type_upload_form_upload", Rails.root.join("spec", "fixtures", "files", "test-pattern.png"))
    expect(page).to have_content("test-pattern.png")
    click_on "Continue"

    expect(intake.reload.current_step).to end_with("/documents/overview")
    expect(page).to have_selector("h1", text: "Great work! Here's a list of what we've collected.")
    click_on "I've shared all my documents"

    # Final Information
    expect(intake.reload.current_step).to end_with("/questions/final-info")
    fill_in "Anything else you'd like your tax preparer to know about your situation?", with: "One of my kids moved away for college, should I include them as a dependent?"
    expect {
      click_on "Submit"
    }.to change(OutgoingTextMessage, :count).by(1).and change(OutgoingEmail, :count).by(1)

    # ID and secondary ID were uploaded
    expect(intake.tax_returns.all? { |tr| tr.current_state == :intake_ready })

    expect(intake.reload.current_step).to end_with("/questions/successfully-submitted")
    expect(page).to have_selector("h1", text: "Success! Your tax information has been submitted.")
    expect(page).to have_text("Client ID number: #{intake.client_id}")
    choose('successfully_submitted_form[satisfaction_face]', option: 'positive').click
    fill_in "successfully_submitted_form_feedback", with: "I am the single filer. I file alone."
    click_on "Continue"

    # Demographic questions
    expect(page).to have_selector("h1", text: "Are you willing to answer some additional questions to help us better serve you?")
    click_on "Continue"
    expect(page).to have_text("How well would you say you can carry on a conversation in English?")
    choose "Well"
    click_on "Continue"
    expect(page).to have_text("How well would you say you read a newspaper in English?")
    choose "Not well"
    click_on "Continue"
    expect(page).to have_text("Do you or any member of your household have a disability?")
    choose "No"
    click_on "Continue"
    expect(page).to have_text("Are you or your spouse a veteran of the U.S. Armed Forces?")
    choose "Yes"
    click_on "Continue"
    expect(intake.reload.current_step).to end_with("/questions/demographic-primary-race")
    expect(page).to have_selector("h1", text: "What is your race and/or ethnicity?")
    check "American Indian or Alaska Native"
    check "Native Hawaiian or other Pacific Islander"
    check "Asian"
    check "Black or African American"
    check "Hispanic or Latino"
    check "Middle Eastern or North African"
    check "White"
    click_on "Submit"

    expect(page).to have_selector("h1", text: "Free tax filing")

    # going back to another page after submit redirects to client login, does not reset current_step
    visit "/questions/work-situations"
    expect(intake.reload.current_step).to end_with("/questions/demographic-primary-race")
    expect(page).to have_selector("h1", text: I18n.t("portal.client_logins.new.title"))
  end

  scenario "new client filing single without dependents skips document flow" do
    intake = intake_up_to_documents

    # IRS guidance page
    expect(intake.reload.current_step).to end_with('/documents/id-guidance')
    click_on I18n.t('general.continue')

    # Upload ID page
    expect(intake.reload.current_step).to end_with('/documents/ids')
    click_on I18n.t('views.layouts.document_upload.dont_have')

    # Help page
    # `intake.reload.current_step` does not yield the Help page's URL
    expect(page).to have_text(I18n.t('documents.documents_help.show.header'))
    click_on I18n.t('documents.documents_help.show.reminder_link')

    # Upload secondary ID doc page
    expect(intake.reload.current_step).to end_with('/documents/ssn-itins')
    click_on I18n.t('views.layouts.document_upload.dont_have')

    # Help page
    expect(page).to have_text(I18n.t('documents.documents_help.show.header'))
    click_on I18n.t('documents.documents_help.show.reminder_link')

    # Documents: Intro page
    # As of ty2024, header is "Now, let's collect your tax documents!"
    expect(intake.reload.current_step).to end_with('/documents/intro')
    click_on I18n.t('general.continue')

    # Share your employment documents page
    expect(intake.reload.current_step).to end_with('/documents/employment')
    click_on I18n.t('views.layouts.document_upload.dont_have')

    # Help page
    expect(page).to have_text(I18n.t('documents.documents_help.show.header'))
    click_on I18n.t('documents.documents_help.show.reminder_link')

    # Additional documents page
    expect(intake.reload.current_step).to end_with('/documents/additional-documents')
    click_on I18n.t('general.continue')

    # List of what we've collected page
    expect(intake.reload.current_step).to end_with('/documents/overview')
    click_on I18n.t('views.documents.overview.finished') # i.e., "I've shared all my documents"

    # "Anything else" page
    expect(intake.reload.current_step).to end_with('/questions/final-info')
    expect {
      click_on I18n.t('general.submit')
    }.to change(OutgoingTextMessage, :count).by(1).and change(OutgoingEmail, :count).by(1)

    # Success! page
    expect(intake.reload.current_step).to end_with('/questions/successfully-submitted')
    # This next `expect` is the whole point of this particular spec test.
    expect(intake.tax_returns.all? { |tr| tr.current_state == :intake_needs_doc_help })
  end

  context "client is included in the returning client experiment" do
    let!(:matching_previous_year_intake) do
      _intake = build(:intake, primary_ssn: "123456789", primary_birth_date: Date.new(1971, 3, 5), product_year: Rails.configuration.product_year - 1)
      create(:client, :with_gyr_return, tax_return_state: :file_accepted, intake: _intake).intake
    end

    let(:returning_client_experiment) { Experiment.find_by(key: ExperimentService::RETURNING_CLIENT_EXPERIMENT) }

    before do
      Experiment.update_all(enabled: true)
      returning_client_experiment.experiment_vita_partners.create(vita_partner: vita_partner)
      allow_any_instance_of(ExperimentService::TreatmentChooser).to receive(:choose).and_return :skip_identity_documents
    end

    scenario "new client filing single without dependents" do
      visit root_path

      click_on I18n.t('general.get_started')

      # fill in personal
      expect(page).to have_selector("h1", text: I18n.t('views.questions.personal_info.title'))
      fill_in I18n.t('views.questions.personal_info.preferred_name'), with: "Gary"
      select I18n.t("date.month_names")[3], from: "personal_info_form_birth_date_month"
      select "5", from: "personal_info_form_birth_date_day"
      select "1971", from: "personal_info_form_birth_date_year"
      fill_in I18n.t('views.questions.personal_info.phone_number'), with: "8286345533"
      fill_in I18n.t('views.questions.personal_info.phone_number_confirmation'), with: "828-634-5533"
      fill_in I18n.t('views.questions.personal_info.zip_code'), with: "20121"
      click_on I18n.t('general.continue')

      intake = Intake.last
      intake_after_triage_up_to_documents(intake)

      # Documents: Intro
      expect(page).to have_selector("h1", text: I18n.t('views.documents.intro.title'))
      click_on "Continue"

      expect(intake.tax_returns.map(&:current_state).uniq).to eq ["intake_ready"]

      expect(page).to have_selector("h1", text: "Share your employment documents")
      upload_file("document_type_upload_form_upload", Rails.root.join("spec", "fixtures", "files", "test-pattern.png"))

      expect(page).to have_content("test-pattern.png")
      expect(page).to have_link("Remove")

      upload_file("document_type_upload_form_upload", Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"))

      expect(page).to have_content("test-pattern.png")
      expect(page).to have_content("picture_id.jpg")
      click_on "Continue"

      expect(page).to have_selector("h1", text: "Please share any additional documents.")
      upload_file("document_type_upload_form_upload", Rails.root.join("spec", "fixtures", "files", "test-pattern.png"))
      expect(page).to have_content("test-pattern.png")
      click_on "Continue"

      expect(intake.reload.current_step).to end_with("/documents/overview")
      expect(page).to have_selector("h1", text: "Great work! Here's a list of what we've collected.")
      click_on "I've shared all my documents"

      # Final Information
      expect(intake.reload.current_step).to end_with("/questions/final-info")
      fill_in "Anything else you'd like your tax preparer to know about your situation?", with: "One of my kids moved away for college, should I include them as a dependent?"
      expect {
        click_on "Submit"
      }.to change(OutgoingTextMessage, :count).by(1).and change(OutgoingEmail, :count).by(1)

      expect(intake.reload.current_step).to end_with("/questions/successfully-submitted")
      expect(page).to have_selector("h1", text: "Success! Your tax information has been submitted.")
      expect(page).to have_text("Please save this number for your records and future reference.")
      expect(page).to have_text("Client ID number: #{intake.client_id}")
      click_on "Continue"
    end
  end
end
