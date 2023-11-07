module StateFileIntakeHelper
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
    perform_enqueued_jobs
    unless Capybara.current_driver == Capybara.javascript_driver
      click_on "HIDDEN TEST-ONLY BUTTON"
    end
  end
end
