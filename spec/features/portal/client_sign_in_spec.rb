require "rails_helper"

RSpec.feature "Signing in" do
  context "As a client", active_job: true do
    let!(:client) do
      create(:intake, primary_first_name: "Carrie", primary_last_name: "Carrot", primary_last_four_ssn: "9876", email_address: "example@example.com", sms_phone_number: "+15005550006").client
    end
    let(:raw_token) { "raw_token" }
    let(:hashed_token) { "hashed_token" }
    before do
      allow(TwilioService).to receive(:send_text_message)
      allow(Devise.token_generator).to receive(:generate).and_return([raw_token, hashed_token])
      allow(Devise.token_generator).to receive(:digest).and_return(hashed_token)
    end

    scenario "requesting a sign-in link with an email address and signing in with a confirmation number" do
      visit new_portal_client_login_path

      expect(page).to have_text "To view your progress, we’ll send you a secure link"
      fill_in "Email address", with: client.intake.email_address
      click_on "Continue"
      expect(page).to have_text "To continue, please visit your secure link."

      perform_enqueued_jobs

      mail = ActionMailer::Base.deliveries.last
      html_body = mail.body.parts[1].decoded
      link = Nokogiri::HTML.parse(html_body).at_css("a")["href"]
      expect(link).to be_present

      puts link
      visit link
      fill_in "Confirmation number", with: client.id
      click_on "Continue"

      expect(page).to have_text("Welcome back Carrie Carrot!")
    end

    scenario "requesting a sign-in link with a phone number and signing in with the last four of a social" do
      visit new_portal_client_login_path

      expect(page).to have_text "To view your progress, we’ll send you a secure link"
      fill_in "Phone for texting", with: "(500) 555-0006"
      click_on "Continue"
      expect(page).to have_text "To continue, please visit your secure link."

      perform_enqueued_jobs

      expected_link = "http://test.host/en/portal/account/raw_token"
      expected_message_body = <<~TEXT
        We received your request for an update on your progress. You can view your progress by following this link
        #{expected_link}
      TEXT

      expect(TwilioService).to have_received(:send_text_message).with(
        to: "+15005550006",
        body: expected_message_body
      )

      visit expected_link

      fill_in "Last 4 of SSN/ITIN", with: "9876"
      click_on "Continue"

      expect(page).to have_text("Welcome back Carrie Carrot!")
    end
  end
end
