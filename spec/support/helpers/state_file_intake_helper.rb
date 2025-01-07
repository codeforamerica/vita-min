module StateFileIntakeHelper
  def filing_year
    MultiTenantService.statefile.current_tax_year
  end

  def step_through_eligibility_screener(us_state:)
    case us_state
    when "ny"
      expect(page).to have_text I18n.t("state_file.questions.ny_eligibility_residence.edit.title")
      choose "state_file_ny_eligibility_residence_form_eligibility_lived_in_state_yes"
      choose "state_file_ny_eligibility_residence_form_eligibility_yonkers_no"
      click_on I18n.t("general.continue")

      choose "state_file_ny_eligibility_out_of_state_income_form_eligibility_out_of_state_income_no"
      choose "state_file_ny_eligibility_out_of_state_income_form_eligibility_part_year_nyc_resident_no"
      click_on I18n.t("general.continue")

      expect(page).to have_text "In #{filing_year}, did you contribute to a 529 college savings account, or did you withdraw funds from a 529 account and use them for non-qualified expenses?"
      choose "state_file_ny_eligibility_college_savings_withdrawal_form_eligibility_withdrew_529_no"
      click_on I18n.t("general.continue")
    when "id"
      expect(page).to have_text I18n.t("state_file.questions.id_eligibility_residence.edit.title", filing_year: filing_year)
      expect(page).to have_text I18n.t("state_file.questions.id_eligibility_residence.edit.emergency_rental_assistance", filing_year: filing_year)
      expect(page).to have_text I18n.t("state_file.questions.id_eligibility_residence.edit.withdrew_msa_fthb", filing_year: filing_year)

      find_by_id('state_file_id_eligibility_residence_form_eligibility_withdrew_msa_fthb_no').click
      find_by_id('state_file_id_eligibility_residence_form_eligibility_emergency_rental_assistance_no').click
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.eligible.id_supported.child_care_deduction")
      expect(page).to have_text I18n.t("state_file.questions.eligible.id_supported.interest_from_obligations")
      expect(page).to have_text I18n.t("state_file.questions.eligible.id_supported.social_security_retirement_deduction")
      expect(page).to have_text I18n.t("state_file.questions.eligible.id_supported.id_child_tax_credit")
      expect(page).to have_text I18n.t("state_file.questions.eligible.id_supported.id_grocery_credit")

      click_on I18n.t("state_file.questions.eligible.edit.credits_not_supported")

      expect(page).to have_text I18n.t("state_file.questions.eligible.id_credits_unsupported.id_college_savings_program")
      expect(page).to have_text I18n.t("state_file.questions.eligible.id_credits_unsupported.id_youth_rehab_contributions")
      expect(page).to have_text I18n.t("state_file.questions.eligible.id_credits_unsupported.maintaining_elderly_disabled_credit")
      expect(page).to have_text I18n.t("state_file.questions.eligible.id_credits_unsupported.long_term_care_insurance_subtraction")
      expect(page).to have_text I18n.t("state_file.questions.eligible.id_credits_unsupported.earned_on_reservation")
      expect(page).to have_text I18n.t("state_file.questions.eligible.id_credits_unsupported.education_contribution_credit")
      expect(page).to have_text I18n.t("state_file.questions.eligible.id_credits_unsupported.itemized_deductions")
      expect(page).to have_text I18n.t("state_file.questions.eligible.id_credits_unsupported.dependents_not_claimed_fed_return")
      expect(page).to have_text I18n.t("state_file.questions.eligible.id_credits_unsupported.voluntary_donations")
      expect(page).to have_text I18n.t("state_file.questions.eligible.id_credits_unsupported.change_in_filing_status")
    when "md"
      expect(page).to have_text I18n.t("state_file.questions.md_eligibility_filing_status.edit.title", year: filing_year)
      click_on I18n.t("general.continue")

      expect(page).to have_text I18n.t("state_file.questions.md_eligibility_filing_status.edit.title", year: filing_year)
      choose I18n.t("general.affirmative"), id: "state_file_md_eligibility_filing_status_form_eligibility_filing_status_mfj_yes"
      choose I18n.t("general.negative"), id: "state_file_md_eligibility_filing_status_form_eligibility_homebuyer_withdrawal_mfj_no"
      choose I18n.t("general.negative"), id: "state_file_md_eligibility_filing_status_form_eligibility_home_different_areas_no"
      click_on I18n.t("general.continue")
    when "nc"
      expect(page).to have_text I18n.t("state_file.questions.nc_eligibility.edit.title", filing_year: filing_year)
      check "state_file_nc_eligibility_form_nc_eligiblity_none"
      click_on I18n.t("general.continue")
    when "nj"
      click_on I18n.t("general.continue")
    end

    unless us_state == "nj"
      expect(page).to have_text I18n.t("state_file.questions.eligible.edit.title1", year: filing_year, state: StateFile::StateInformationService.state_name(us_state))
      click_on "Continue"
    end
  end

  def step_through_initial_authentication(contact_preference: :text_message)
    expect(page).to have_text I18n.t("state_file.questions.contact_preference.edit.title")

    case contact_preference
    when :text_message
      click_on "Text me a code"

      expect(page).to have_text "Enter your phone number"
      fill_in "Your phone number", with: "4153334444"
      click_on "Send code"


      expect(strip_html_tags(page.body)).to have_text strip_html_tags(I18n.t("state_file.questions.verification_code.edit.title_html", contact_info: '(415) 333-4444'))
      expect(page).to have_text "We’ve sent your code to (415) 333-4444"

      perform_enqueued_jobs
      sms = FakeTwilioClient.messages.last
      code = sms.body.to_s.match(/\s(\d{6})[.]/)[1]
    when :email
      click_on "Email me a code"

      expect(page).to have_text "Enter your email address"
      fill_in I18n.t("state_file.questions.email_address.edit.email_address_label"), with: "someone@example.com"
      click_on "Send code"
      save_and_open_page
      expect(page).to have_text "We’ve sent your code to someone@example.com"

      perform_enqueued_jobs
      mail = ActionMailer::Base.deliveries.last
      code = mail.html_part.body.to_s.match(%r{<strong> (\d{6})\.</strong>})[1]
    end

    fill_in "Enter the 6-digit code", with: code
    click_on "Verify code"

    expect(page).to have_text "Code verified!"
    click_on "Continue"
  end

  def step_through_df_data_transfer(sample_name = "Transfer my #{filing_year} federal tax return to FileYourStateTaxes")
    expect(page).to have_text I18n.t('state_file.questions.initiate_data_transfer.edit.title')
    click_on I18n.t('state_file.questions.initiate_data_transfer.data_transfer_buttons.from_fake_df_page')

    expect(page).to have_text "Your #{filing_year} federal tax return is ready to transfer to your state tax return."
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
    click_on I18n.t("general.continue")
  end

  def assert_flow_explorer_sample_params_includes_everything(us_state)
    # Enforce that the attributes used to generate state file intakes in the Flow Explorer
    # include at least every property that a state file intake would have at the end of
    # one of our feature tests
    #
    # e.g. if we introduced a new 'received_railroad_benefits' enum, and the feature test
    # fills it out, it should be included in the params used by SampleStateFileIntakeGenerator

    intake = StateFile::StateInformationService.intake_class(us_state).last
    flow_explorer_params = FlowsController::SampleStateFileIntakeGenerator.send("#{us_state}_attributes")
    intake_attribute_keys = intake.attributes.select { |_k, v| v }.keys - %w[id primary_state_id_id made_az321_contributions]
    flow_explorer_generated_intake_keys = flow_explorer_params.keys.map(&:to_s)
    missing_keys = intake_attribute_keys - flow_explorer_generated_intake_keys
    expect(missing_keys).to eq([])
  end
end
