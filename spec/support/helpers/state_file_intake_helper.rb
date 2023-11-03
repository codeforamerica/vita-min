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

    # sending the authentication code is currently non-functional
    # this page is a place holder and does not validate the code
    click_on "Verify code"

    expect(page).to have_text "Code verified!"
    click_on "Continue"
  end
end
