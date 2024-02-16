module StateFileIntakeHelper
  def step_through_eligibility_screener(us_state:)
    expect(page).to have_text I18n.t("state_file.questions.eligibility_residence.edit.title")
    case us_state
    when "ny"
      choose "state_file_ny_eligibility_residence_form_eligibility_lived_in_state_yes"
      choose "state_file_ny_eligibility_residence_form_eligibility_yonkers_no"
      click_on "Continue"

      choose "state_file_ny_eligibility_out_of_state_income_form_eligibility_out_of_state_income_no"
      choose "state_file_ny_eligibility_out_of_state_income_form_eligibility_part_year_nyc_resident_no"
      click_on "Continue"

      expect(page).to have_text "In 2023, did you contribute to a 529 college savings account, or did you withdraw funds from a 529 account and use them for non-qualified expenses?"
      choose "state_file_ny_eligibility_college_savings_withdrawal_form_eligibility_withdrew_529_no"
    when "az"
      choose "state_file_az_eligibility_residence_form_eligibility_lived_in_state_yes"
      choose "state_file_az_eligibility_residence_form_eligibility_married_filing_separately_no"
      click_on "Continue"

      choose "state_file_az_eligibility_out_of_state_income_form_eligibility_out_of_state_income_no"
      choose "state_file_az_eligibility_out_of_state_income_form_eligibility_529_for_non_qual_expense_no"
    end
    click_on "Continue"

    expect(page).to have_text I18n.t("state_file.questions.eligible.edit.title1")
    click_on "Continue"
  end

  def step_through_initial_authentication(contact_preference: :text_message)
    expect(page).to have_text I18n.t("state_file.questions.contact_preference.edit.title")

    case contact_preference
    when :text_message
      click_on "Text me a code"

      expect(page).to have_text "Enter your phone number"
      fill_in "Your phone number", with: "4153334444"
      click_on "Send code"


      expect(page).to have_text I18n.t("state_file.questions.verification_code.edit.title")
      expect(page).to have_text "We’ve sent your code to (415) 333-4444."

      perform_enqueued_jobs
      sms = FakeTwilioClient.messages.last
      code = sms.body.to_s.match(/\s(\d{6})[.]/)[1]
    when :email
      click_on "Email me a code"

      expect(page).to have_text "Enter your email address"
      fill_in I18n.t("state_file.questions.email_address.edit.email_address_label"), with: "someone@example.com"
      click_on "Send code"

      expect(page).to have_text I18n.t("state_file.questions.verification_code.edit.title")
      expect(page).to have_text "We’ve sent your code to someone@example.com."

      perform_enqueued_jobs
      mail = ActionMailer::Base.deliveries.last
      code = mail.html_part.body.to_s.match(/\s(\d{6})[.]/)[1]
    end

    fill_in "Enter the 6-digit code", with: code
    click_on "Verify code"

    expect(page).to have_text "Code verified!"
    click_on "Continue"
  end

  def step_through_df_data_transfer(sample_name = "Transfer my 2023 federal tax return to FileYourStateTaxes")
    expect(page).to have_text I18n.t('state_file.questions.initiate_data_transfer.edit.title')
    click_on I18n.t('state_file.questions.initiate_data_transfer.data_transfer_buttons.from_fake_df_page')

    expect(page).to have_text "Your 2023 federal tax return is ready to transfer to your state tax return."
    click_on sample_name

    expect(page).to have_text "Just a moment, we’re transferring your federal tax return to complete parts of your state return."
    if Capybara.current_driver == Capybara.javascript_driver
      # Ensure JavaScript is waiting for our broadcast before we run the job that will do it
      expect(page).to have_css('[data-after-data-transfer-button][data-subscribed]', visible: :any)
    end
    perform_enqueued_jobs
    unless Capybara.current_driver == Capybara.javascript_driver
      find_link("HIDDEN BUTTON", visible: :any).click
    end
  end

  def assert_flow_explorer_sample_params_includes_everything(us_state)
    # Enforce that the attributes used to generate state file intakes in the Flow Explorer
    # include at least every property that a state file intake would have at the end of
    # one of our feature tests
    #
    # e.g. if we introduced a new 'received_railroad_benefits' enum, and the feature test
    # fills it out, it should be included in the params used by SampleStateFileIntakeGenerator

    intake = {}
    flow_explorer_params = {}

    case us_state
    when 'az'
      intake = StateFileAzIntake.last
      flow_explorer_params = FlowsController::SampleStateFileIntakeGenerator.az_attributes
    when 'ny'
      intake = StateFileNyIntake.last
      flow_explorer_params = FlowsController::SampleStateFileIntakeGenerator.ny_attributes
    end

    intake_attribute_keys = intake.attributes.select { |_k, v| v }.keys - %w[id primary_state_id_id]
    flow_explorer_generated_intake_keys = flow_explorer_params.keys.map(&:to_s)
    missing_keys = intake_attribute_keys - flow_explorer_generated_intake_keys
    expect(missing_keys).to eq([])
  end
end
