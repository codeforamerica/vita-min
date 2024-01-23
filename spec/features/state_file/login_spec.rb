require "rails_helper"

RSpec.feature "Logging in with an existing account" do
  include StateFileIntakeHelper
  let(:phone_number) { "+15551231234" }
  let(:email_address) { "someone@example.com" }
  let(:ssn) { "111223333" }
  let(:hashed_ssn) { "hashed_ssn" }
  let!(:az_intake) { create :state_file_az_intake, phone_number: phone_number, hashed_ssn: hashed_ssn }
  let!(:ny_intake) { create :state_file_ny_intake, email_address: email_address, hashed_ssn: hashed_ssn }
  let(:verification_code) { "000004" }
  let(:hashed_verification_code) { "hashed_verification_code" }
  let(:double_hashed_verification_code) { "double_hashed_verification_code" }

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
    allow(SsnHashingService).to receive(:hash).with(ssn).and_return hashed_ssn
    allow(VerificationCodeService).to receive(:generate).with(anything).and_return [verification_code, hashed_verification_code]

    # mock case for correct code
    allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with(email_address, verification_code).and_return(hashed_verification_code)
    allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with(phone_number, verification_code).and_return(hashed_verification_code)
    # mock case for wrong code
    allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with(phone_number, "999999").and_return("hashed_wrong_verification_code")
    allow(TwilioService).to receive(:send_text_message)
  end

  scenario "signing in with phone number" do
    visit "/az/login-options"
    expect(page).to have_text "Sign in to FileYourStateTaxes"
    click_on "Sign in with phone number"

    expect(page).to have_text "Sign in with your phone number"
    fill_in "Your phone number", with: phone_number
    perform_enqueued_jobs do
      click_on I18n.t("state_file.questions.email_address.edit.action")
    end

    expect(TwilioService).to have_received(:send_text_message).with(
      to: phone_number,
      body: "Your 6-digit FileYourStateTaxes verification code is: #{verification_code}. This code will expire after two days.",
      status_callback: twilio_update_status_url(OutgoingMessageStatus.last.id, locale: nil, host: 'test.host')
    )

    expect(page).to have_text "Enter the code to continue"
    fill_in "Enter the 6-digit code", with: verification_code
    click_on "Verify code"

    expect(page).to have_text "Code verified! Authentication needed to continue."
    fill_in "Enter your Social Security number or ITIN. For example, 123-45-6789.", with: ssn
    click_on "Continue"

    expect(page).to have_text "Your federal tax return is now transferred. We completed some sections to save you time."
  end

  scenario "signing in with email" do
    visit "/ny/login-options"
    expect(page).to have_text "Sign in to FileYourStateTaxes"
    click_on "Sign in with email"

    expect(page).to have_text "Sign in with your email address"
    fill_in I18n.t("state_file.intake_logins.new.email_address.label"), with: email_address
    perform_enqueued_jobs do
      click_on I18n.t("state_file.questions.email_address.edit.action")
    end

    mail = ActionMailer::Base.deliveries.last
    expect(mail.html_part.body.to_s).to include("Your six-digit verification code for FileYourStateTaxes is: #{verification_code}. This code will expire after two days.")

    expect(page).to have_text "Enter the code to continue"
    fill_in "Enter the 6-digit code", with: verification_code
    click_on "Verify code"

    expect(page).to have_text "Code verified! Authentication needed to continue."
    fill_in "Enter your Social Security number or ITIN. For example, 123-45-6789.", with: ssn
    click_on "Continue"

    expect(page).to have_text "Your federal tax return is now transferred. We completed some sections to save you time."
  end
end