module StateFileIntakeHelper
  def step_through_eligibility_screener(us_state:)
    expect(page).to have_text "First, let's see if you can use this tool to file your taxes"
    case us_state
    when "ny"
      choose "state_file_ny_eligibility_residence_form_eligibility_lived_in_state_yes"
      choose "state_file_ny_eligibility_residence_form_eligibility_yonkers_no"
      click_on "Continue"

      choose "state_file_ny_eligibility_out_of_state_income_form_eligibility_out_of_state_income_no"
      choose "state_file_ny_eligibility_out_of_state_income_form_eligibility_part_year_nyc_resident_no"
    when "az"
      choose "state_file_az_eligibility_residence_form_eligibility_lived_in_state_yes"
      choose "state_file_az_eligibility_residence_form_eligibility_married_filing_separately_no"
      click_on "Continue"

      choose "state_file_az_eligibility_out_of_state_income_form_eligibility_out_of_state_income_no"
      choose "state_file_az_eligibility_out_of_state_income_form_eligibility_529_for_non_qual_expense_no"
    end
    click_on "Continue"
  end

  def step_through_initial_authentication(contact_preference: :text_message)
    expect(page).to have_text "Next, set up your account with a quick code"

    case contact_preference
    when :text_message
      click_on "Text me a code"

      expect(page).to have_text "Enter your phone number"
      fill_in "Your phone number", with: "4153334444"
      click_on "Send code"


      expect(page).to have_text "Verify the code to continue"
      expect(page).to have_text "A message with your code has been sent to (415) 333-4444."

      perform_enqueued_jobs
      sms = FakeTwilioClient.messages.last
      code = sms.body.to_s.match(/\s(\d{6})[.]/)[1]
    when :email
      click_on "Email me a code"

      expect(page).to have_text "Enter your email address"
      fill_in "Your email address (avoid using a temporary email)", with: "someone@example.com"
      click_on "Send code"

      expect(page).to have_text "Verify the code to continue"
      expect(page).to have_text "A message with your code has been sent to someone@example.com."

      perform_enqueued_jobs
      mail = ActionMailer::Base.deliveries.last
      code = mail.html_part.body.to_s.match(/\s(\d{6})[.]/)[1]
    end

    fill_in "Enter the 6-digit code", with: code
    click_on "Verify code"

    expect(page).to have_text "Code verified!"
    click_on "Continue"
  end

  def step_through_df_data_transfer
    expect(page).to have_text I18n.t('state_file.questions.initiate_data_transfer.edit.title')
    click_on I18n.t('state_file.questions.initiate_data_transfer.edit.button')

    expect(page).to have_text "Your 2023 federal tax return is ready to transfer to your state tax return."
    click_on "Transfer my 2023 federal tax return to FileYourStateTaxes"

    expect(page).to have_text "Just a moment, we’re transferring your federal tax return to pre-fill parts of your state return."
    if Capybara.current_driver == Capybara.javascript_driver
      # Ensure JavaScript is waiting for our broadcast before we run the job that will do it
      expect(page).to have_css('[data-after-data-transfer-button][data-subscribed]', visible: :any)
    end
    perform_enqueued_jobs
    unless Capybara.current_driver == Capybara.javascript_driver
      find_link("HIDDEN BUTTON", visible: :any).click
    end
  end
end
