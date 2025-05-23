require "rails_helper"

RSpec.feature "Logging in" do
  context "With a client who consented", active_job: true do
    let(:twilio_service) { instance_double TwilioService }
    let!(:client) { create :client, intake: intake }
    let(:intake) { build :intake, :primary_consented, preferred_name: "Carrie", primary_first_name: "Carrie", primary_last_name: "Carrot", primary_last_four_ssn: "9876", email_address: "example@example.com", sms_phone_number: "+15005550006", sms_notification_opt_in: "yes" }
    let!(:tax_return) { create(:gyr_tax_return, :ready_to_sign, client: client) }

    context "As a client logging in from the login page" do
      context "signing in with verification code" do
        let(:hashed_verification_code) { "hashed_verification_code" }
        let(:double_hashed_verification_code) { "double_hashed_verification_code" }

        before do
          allow(VerificationCodeService).to receive(:generate).with(anything).and_return ["000004", hashed_verification_code]
          # mock case for correct code
          allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with(client.intake.email_address, "000004").and_return(hashed_verification_code)
          allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with(client.intake.sms_phone_number, "000004").and_return(hashed_verification_code)
          # mock case for wrong code
          allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with(client.intake.sms_phone_number, "999999").and_return("hashed_wrong_verification_code")
          allow(TwilioService).to receive(:new).and_return twilio_service
          allow(twilio_service).to receive(:send_text_message)
        end

        scenario "requesting a verification code with an email address and signing in with a client id" do
          visit new_portal_client_login_path

          expect(page).to have_text I18n.t("portal.client_logins.new.title")
          fill_in "Email address", with: client.intake.email_address
          perform_enqueued_jobs do
            click_on "Send code"
            expect(page).to have_text "Let’s verify that code!"
          end

          mail = ActionMailer::Base.deliveries.last
          expect(mail.html_part.body.to_s).to include("Your six-digit verification code for GetYourRefund is: <strong> 000004.</strong> This code will expire after 10 minutes.")

          fill_in "Enter 6 digit code", with: "000004"
          click_on "Verify"

          fill_in "Client ID or Last 4 of SSN/ITIN", with: client.id
          click_on "Continue"

          expect(page).to have_text("Welcome back Carrie!")
        end

        scenario "signing out" do
          login_as(client, scope: :client)
          visit portal_root_path
          expect(page).to have_text("Carrie")
          within ".toolbar" do
            click_on "Sign out"
          end
          visit portal_root_path
          expect(page).not_to have_text("Carrie")
        end

        scenario "requesting a verification code with a phone number and signing in with the last four of a social" do
          visit new_portal_client_login_path

          expect(page).to have_text I18n.t("portal.client_logins.new.title")
          fill_in "Cell phone number", with: "(500) 555-0006"

          perform_enqueued_jobs do
            click_on "Send code"
            expect(page).to have_text "Let’s verify that code!"
            expect(page).to have_text("A message with your code has been sent to: (500) 555-0006")
          end

          expect(twilio_service).to have_received(:send_text_message).with(
            to: "+15005550006",
            body: "Your 6-digit GetYourRefund verification code is: 000004. This code will expire after 10 minutes.",
            status_callback: twilio_update_status_url(OutgoingMessageStatus.last.id, locale: nil, host: 'test.host')
          )

          fill_in "Enter 6 digit code", with: "000004"
          click_on "Verify"

          fill_in "Client ID or Last 4 of SSN/ITIN", with: "9876"
          click_on "Continue"

          expect(page).to have_text("Welcome back Carrie!")
        end

        scenario "getting locked out due to too many wrong verification codes" do
          visit new_portal_client_login_path

          expect(page).to have_text I18n.t("portal.client_logins.new.title")
          fill_in "Cell phone number", with: "(500) 555-0006"

          perform_enqueued_jobs do
            click_on "Send code"
            expect(page).to have_text "Let’s verify that code!"
          end

          fill_in "Enter 6 digit code", with: "999999"
          click_on "Verify"

          fill_in "Enter 6 digit code", with: "999999"
          click_on "Verify"

          fill_in "Enter 6 digit code", with: "999999"
          click_on "Verify"

          expect(page).to have_text("This account has been locked")
        end

        scenario "getting through with max possible number of tries" do
          visit new_portal_client_login_path

          expect(page).to have_text I18n.t("portal.client_logins.new.title")
          fill_in "Cell phone number", with: "(500) 555-0006"

          perform_enqueued_jobs do
            click_on "Send code"
            expect(page).to have_text "Let’s verify that code!"
          end

          fill_in "Enter 6 digit code", with: "999999"
          click_on "Verify"

          fill_in "Enter 6 digit code", with: "999999"
          click_on "Verify"

          fill_in "Enter 6 digit code", with: "000004"
          click_on "Verify"

          fill_in "Client ID or Last 4 of SSN/ITIN", with: "9875"
          click_on "Continue"

          fill_in "Client ID or Last 4 of SSN/ITIN", with: "9877"
          click_on "Continue"

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
          # Set up login link
          EmailVerificationCodeService.request_code(email_address: "example@example.com", visitor_id: "anything", service_type: :gyr)
        end

        scenario "visiting sign-in link at its current url" do
          visit edit_portal_client_login_path(id: "raw_token", locale: "es")
          fill_in "ID de cliente o los 4 últimos de SSN/ITIN", with: "9876"
          click_on "Continuar"

          expect(page).to have_text("Bienvenido de nuevo Carrie!")
        end

        scenario "visiting a sign-in link with the pre-march-2021 url" do
          # Validate with empty locale
          visit "/portal/account/raw_token"
          fill_in "Client ID or Last 4 of SSN/ITIN", with: "9876"

          # Validate with Spanish
          visit "/es/portal/account/raw_token"
          fill_in "ID de cliente o los 4 últimos de SSN/ITIN", with: "9876"
          click_on "Continuar"

          expect(page).to have_text("Bienvenido de nuevo Carrie!")
        end
      end
    end

    context "As a client trying to access a protected page" do
      let(:hashed_verification_code) { "hashed_verification_code" }
      let(:double_hashed_verification_code) { "double_hashed_verification_code" }

      before do
        allow(VerificationCodeService).to receive(:generate).with(anything).and_return ["000004", hashed_verification_code]
        allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with(client.intake.email_address, "000004").and_return(hashed_verification_code)
      end

      scenario "getting redirected to the page client was trying to access after login" do
        visit portal_tax_return_authorize_signature_path(locale: "es", tax_return_id: tax_return.id)

        expect(page).to have_text I18n.t("portal.client_logins.new.title", locale: "es")
        fill_in I18n.t("views.questions.email_address.email_address", locale: "es"), with: client.intake.email_address

        perform_enqueued_jobs do
          click_on I18n.t("portal.client_logins.new.send_code", locale: "es")
          expect(page).to have_text I18n.t("portal.client_logins.enter_verification_code.title", locale: "es")
        end

        mail = ActionMailer::Base.deliveries.last
        expect(mail.html_part.body.to_s).to have_text("de seis dígitos para GetYourRefund es: 000004. Este código expirará después de 10 minutos.")

        fill_in I18n.t('portal.client_logins.enter_verification_code.enter_6_digit_code', locale: "es"), with: "000004"
        click_on I18n.t('portal.client_logins.enter_verification_code.verify', locale: "es")

        fill_in I18n.t('portal.client_logins.edit.last_four_or_client_id', locale: "es"), with: client.id
        click_on I18n.t('general.continue', locale: "es")

        expect(page).to have_text I18n.t("portal.tax_returns.authorize_signature.heading", locale: "es")
      end
    end
  end
end
