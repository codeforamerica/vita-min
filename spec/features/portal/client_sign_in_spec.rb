require "rails_helper"

RSpec.feature "Signing in" do
  context "As a client", active_job: true do
    let!(:client) do
      create(:intake, preferred_name: "Carrie", primary_first_name: "Carrie", primary_last_name: "Carrot", primary_last_four_ssn: "9876", email_address: "example@example.com", sms_phone_number: "+15005550006").client
    end

    context "signing in with verification code" do
      let(:hashed_verification_code) { "hashed_verification_code" }
      let(:double_hashed_verification_code) { "double_hashed_verification_code" }

      before do
        allow(VerificationCodeService).to receive(:generate).with(anything).and_return ["000004", hashed_verification_code]
        allow(Devise.token_generator).to receive(:digest).and_return(double_hashed_verification_code)
        allow(TwilioService).to receive(:send_text_message)
      end

      scenario "requesting a verification code with an email address and signing in with a client id" do
        visit new_portal_client_login_path

        expect(page).to have_text "To view your progress, we’ll send you a secure code"
        fill_in "Email address", with: client.intake.email_address
        click_on "Send code"
        expect(page).to have_text "Let’s verify that code!"

        perform_enqueued_jobs

        mail = ActionMailer::Base.deliveries.last
        text_body = mail.body.parts[0].decoded
        expect(text_body).to include("Your 6-digit GetYourRefund verification code is: 000004. This code will expire after two days.")

        fill_in "Enter 6 digit code", with: "000004"
        click_on "Verify"

        fill_in "Client ID or Last 4 of SSN/ITIN", with: client.id
        click_on "Continue"

        expect(page).to have_text("Welcome back Carrie!")
      end

      scenario "requesting a verification code with a phone number and signing in with the last four of a social" do
        visit new_portal_client_login_path

        expect(page).to have_text "To view your progress, we’ll send you a secure code"
        fill_in "Cell phone number", with: "(500) 555-0006"
        click_on "Send code"
        expect(page).to have_text "Let’s verify that code!"

        perform_enqueued_jobs

        expect(TwilioService).to have_received(:send_text_message).with(
          to: "+15005550006",
          body: "Your 6-digit GetYourRefund verification code is: 000004. This code will expire after two days."
        )

        fill_in "Enter 6 digit code", with: "000004"
        click_on "Verify"

        fill_in "Client ID or Last 4 of SSN/ITIN", with: "9876"
        click_on "Continue"

        expect(page).to have_text("Welcome back Carrie!")
      end
    end

    context "signing in with link" do
      let(:raw_token) { "raw_token" }
      let(:hashed_token) { "hashed_token" }

      before do
        allow(Devise.token_generator).to receive(:generate).and_return [raw_token, hashed_token]
        allow(Devise.token_generator).to receive(:digest).and_return(hashed_token)
      end

      before do
        # Set up login link
        ClientLoginsService.issue_email_token("example@example.com")
      end

      scenario "visiting sign-in link at its current url" do
        visit edit_portal_client_login_path(id: "raw_token", locale: "es")
        fill_in "ID de cliente o los 4 últimos de SSN / ITIN", with: "9876"
        click_on "Continuar"

        expect(page).to have_text("Bienvenido de nuevo Carrie!")
      end

      scenario "visiting a sign-in link with the pre-march-2021 url" do
        # Validate with empty locale
        visit "/portal/account/raw_token"
        fill_in "Client ID or Last 4 of SSN/ITIN", with: "9876"

        # Validate with Spanish
        visit "/es/portal/account/raw_token"
        fill_in "ID de cliente o los 4 últimos de SSN / ITIN", with: "9876"
        click_on "Continuar"

        expect(page).to have_text("Bienvenido de nuevo Carrie!")
      end
    end
  end
end
