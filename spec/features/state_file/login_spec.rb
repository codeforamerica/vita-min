require "rails_helper"

RSpec.feature "Logging in" do
  include StateFileIntakeHelper
  let(:twilio_service) { instance_double TwilioService }
  let(:phone_number) { "+15551231234" }
  let(:email_address) { "someone@example.com" }
  let(:ssn) { "111223333" }
  let(:hashed_ssn) { "hashed_ssn" }
  let(:verification_code) { "000004" }
  let(:hashed_verification_code) { "hashed_verification_code" }

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
    allow(SsnHashingService).to receive(:hash).with(ssn).and_return hashed_ssn
    allow(VerificationCodeService).to receive(:generate).with(anything).and_return [verification_code, hashed_verification_code]

    # mock case for correct code
    allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with(email_address, verification_code).and_return(hashed_verification_code)
    allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with(phone_number, verification_code).and_return(hashed_verification_code)
    # mock case for wrong code
    allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with(phone_number, "999999").and_return("hashed_wrong_verification_code")
    allow(TwilioService).to receive(:new).and_return twilio_service
    allow(twilio_service).to receive(:send_text_message)
    Flipper.enable :sms_notifications
  end

  context "with an existing account" do
    let!(:az_intake) {
      create :state_file_az_intake,
             phone_number: phone_number,
             hashed_ssn: hashed_ssn,
             df_data_import_succeeded_at: 5.minutes.ago,
             phone_number_verified_at: DateTime.now
    }
    let!(:az_intake_2) {
      create :state_file_az_intake,
             email_address: email_address,
             hashed_ssn: hashed_ssn,
             df_data_import_succeeded_at: 5.minutes.ago,
             email_address_verified_at: DateTime.now
    }

    scenario "signing in with phone number" do
      sign_in_request_via_phone_number

      expect(page).to have_text "Enter the code to continue"
      fill_in "Enter the 6-digit code", with: verification_code
      click_on "Verify code"

      expect(page).to have_text I18n.t("state_file.intake_logins.edit.title")
      fill_in "Enter your Social Security number or ITIN. For example, 123-45-6789.", with: ssn
      click_on "Continue"

      expect(page).to have_text "let me edit the response XML"
    end

    scenario "signing in with email" do
      visit "/login-options"
      expect(page).to have_text "Sign in to FileYourStateTaxes"
      click_on "Sign in with email"

      expect(page).to have_text "Sign in with your email address"
      fill_in I18n.t("state_file.intake_logins.new.email_address.label"), with: email_address
      perform_enqueued_jobs do
        click_on I18n.t("state_file.questions.email_address.edit.action")
      end

      mail = ActionMailer::Base.deliveries.last
      expect(mail.html_part.body.to_s).to include("Your six-digit verification code for FileYourStateTaxes is: <strong> #{verification_code}.</strong> This code will expire after 10 minutes.")

      expect(page).to have_text "Enter the code to continue"
      fill_in "Enter the 6-digit code", with: verification_code
      click_on "Verify code"

      expect(page).to have_text I18n.t("state_file.intake_logins.edit.title")
      fill_in "Enter your Social Security number or ITIN. For example, 123-45-6789.", with: ssn
      click_on "Continue"

      expect(page).to have_text "let me edit the response XML"
    end

    scenario "get locked out after three tries" do
      sign_in_request_via_phone_number

      expect(page).to have_text "Enter the code to continue"
      fill_in "Enter the 6-digit code", with: "999999"
      click_on "Verify code"

      expect(page).to have_text "Enter the code to continue"
      fill_in "Enter the 6-digit code", with: "999999"
      click_on "Verify code"

      expect(page).to have_text "Enter the code to continue"
      fill_in "Enter the 6-digit code", with: "999999"
      click_on "Verify code"

      expect(page).to have_text I18n.t("state_file.intake_logins.account_locked.title")
    end

    context "signing in on locked account" do
      before do
        az_intake.update(locked_at: 5.minutes.ago, failed_attempts: 3)
      end

      context "before unlocked_in time" do
        context "get verification code correct" do
          scenario "gets account locked page" do
            sign_in_request_via_phone_number

            expect(page).to have_text "Enter the code to continue"
            fill_in "Enter the 6-digit code", with: verification_code
            click_on "Verify code"

            expect(page).to have_text I18n.t("state_file.intake_logins.account_locked.title")
          end
        end

        context "get verification code wrong" do
          scenario "gets account locked page" do
            sign_in_request_via_phone_number

            expect(page).to have_text "Enter the code to continue"
            fill_in "Enter the 6-digit code", with: "999999"
            click_on "Verify code"

            expect(page).to have_text I18n.t("state_file.intake_logins.account_locked.title")
          end
        end
      end

      context "after unlocked_in time" do
        before do
          az_intake.update(locked_at: 32.minutes.ago, failed_attempts: 3)
        end

        context "gets verification code wrong" do
          scenario "gets enter_verification_code screen again" do
            sign_in_request_via_phone_number

            expect(page).to have_text "Enter the code to continue"
            fill_in "Enter the 6-digit code", with: "999999"
            click_on "Verify code"

            expect(page).to have_text I18n.t("state_file.intake_logins.enter_verification_code.title")
          end
        end

        context "gets verification code right" do
          context "gets SSN correct" do
            scenario "gets to login and move forward" do
              sign_in_request_via_phone_number

              expect(page).to have_text "Enter the code to continue"
              fill_in "Enter the 6-digit code", with: verification_code
              click_on "Verify code"

              expect(page).to have_text I18n.t("state_file.intake_logins.edit.title")
              fill_in "Enter your Social Security number or ITIN. For example, 123-45-6789.", with: ssn
              click_on "Continue"

              expect(page).to have_text "let me edit the response XML"
            end
          end

          context "gets SSN wrong" do
            let(:wrong_ssn) { "887223344" }

            before do
              allow(SsnHashingService).to receive(:hash).with(wrong_ssn).and_return "wrong_hashed_ssn"
            end

            scenario "will be able to re-enter SSN 3 times" do
              sign_in_request_via_phone_number

              expect(page).to have_text "Enter the code to continue"
              fill_in "Enter the 6-digit code", with: verification_code
              click_on "Verify code"

              expect(page).to have_text I18n.t("state_file.intake_logins.edit.title")
              fill_in "Enter your Social Security number or ITIN. For example, 123-45-6789.", with: wrong_ssn
              click_on "Continue"

              expect(page).to have_text I18n.t("state_file.intake_logins.edit.title")
              expect(page).to have_text I18n.t("state_file.intake_logins.form.errors.bad_input")
              fill_in "Enter your Social Security number or ITIN. For example, 123-45-6789.", with: wrong_ssn
              click_on "Continue"

              expect(page).to have_text I18n.t("state_file.intake_logins.edit.title")
              expect(page).to have_text I18n.t("state_file.intake_logins.form.errors.bad_input")
              fill_in "Enter your Social Security number or ITIN. For example, 123-45-6789.", with: wrong_ssn
              click_on "Continue"

              expect(page).to have_text I18n.t("state_file.intake_logins.account_locked.title")
            end
          end
        end
      end
    end
  end

  context "with an account that does not exist" do
    scenario "attempting to sign in with non-existent email" do
      visit "/login-options"
      expect(page).to have_text "Sign in to FileYourStateTaxes"
      click_on "Sign in with email"

      expect(page).to have_text "Sign in with your email address"
      fill_in I18n.t("state_file.intake_logins.new.email_address.label"), with: "nonexistent@example.com"
      click_button I18n.t("state_file.questions.email_address.edit.action")

      expect(page).to have_text "Sorry, we don’t have an account registered for that email address. Click here to get started with FileYourStateTaxes."
    end

    scenario "attempting to sign in with non-existent phone number" do
      visit "/login-options"
      expect(page).to have_text "Sign in to FileYourStateTaxes"
      click_on "Sign in with phone number"

      expect(page).to have_text "Sign in with your phone number"
      fill_in I18n.t("state_file.intake_logins.new.sms_phone_number.label"), with: "+15555555555"
      click_button I18n.t("state_file.questions.email_address.edit.action")

      expect(page).to have_text "Sorry, we don’t have an account registered for that phone number. Click here to get started with FileYourStateTaxes."
    end
  end

  def sign_in_request_via_phone_number
    visit "/login-options"
    expect(page).to have_text "Sign in to FileYourStateTaxes"
    click_on "Sign in with phone number"

    expect(page).to have_text "Sign in with your phone number"
    fill_in "Your phone number", with: phone_number
    perform_enqueued_jobs do
      click_on I18n.t("state_file.questions.email_address.edit.action")
    end

    expect(twilio_service).to have_received(:send_text_message).with(
      to: phone_number,
      body: "Your 6-digit FileYourStateTaxes verification code is: #{verification_code}. This code will expire after 10 minutes.",
      )
  end
end
