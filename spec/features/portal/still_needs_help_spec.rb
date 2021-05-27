require "rails_helper"

RSpec.feature "Still Needs Help" do
  context "When a client has triggered the Still Needs Help flow", active_job: true do
    let(:tax_return) { create(:tax_return, status: :file_not_filing) }
    let(:client) { create :client, tax_returns: [tax_return], triggered_still_needs_help_at: Time.now }
    let!(:intake) { create :intake, :primary_consented, preferred_name: "Carrie", primary_first_name: "Carrie", primary_last_name: "Carrot", primary_last_four_ssn: "9876", email_address: "example@example.com", sms_phone_number: "+15005550006", client: client }

    context "As a client visiting the portal" do
      let(:hashed_verification_code) { "hashed_verification_code" }
      let(:double_hashed_verification_code) { "double_hashed_verification_code" }

      before do
        allow(VerificationCodeService).to receive(:generate).with(anything).and_return ["000004", hashed_verification_code]
        # mock case for correct code
        allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with(client.intake.email_address, "000004").and_return(hashed_verification_code)
        allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with(client.intake.sms_phone_number, "000004").and_return(hashed_verification_code)
      end

      scenario "logging in via needs help link" do
        visit portal_still_needs_helps_path

        expect(page).to have_text "To view your progress, we’ll send you a secure code"
        fill_in "Email address", with: client.intake.email_address
        click_on "Send code"
        expect(page).to have_text "Let’s verify that code!"

        perform_enqueued_jobs

        mail = ActionMailer::Base.deliveries.last
        expect(mail.html_part.body.to_s).to include("Your 6-digit GetYourRefund verification code is: 000004. This code will expire after two days.")

        fill_in "Enter 6 digit code", with: "000004"
        click_on "Verify"

        fill_in "Client ID or Last 4 of SSN/ITIN", with: client.id
        click_on "Continue"

        expect(page).to have_text("Are you still interested in filing your taxes with us?")
      end

      context "with a loggged-in client" do
        before do
        end

        scenario "telling us they do not need help" do
        visit portal_root_path
        expect(page).not_to have_text "Welcome back Carrie!"

        next # skip rest of test with `next` keyword

        expect(page).to have_text "Are you still interested in filing your taxes with us?"

        click_on "No, I'm not interested"
        expect(page).to have_text "Thank you for using GetYourRefund."

        click_on "Return to home"
        expect(page).to have_text "Welcome back Carrie!"
        end
      end
    end
  end
end
