require "rails_helper"

RSpec.feature "Session duration" do
  def authenticate_client(client)
    expect(page).to have_text "To view your progress, we’ll send you a secure code"
    fill_in "Email address", with: client.intake.email_address
    click_on "Send code"
    expect(page).to have_text "Let’s verify that code!"

    perform_enqueued_jobs

    mail = ActionMailer::Base.deliveries.last
    code = mail.html_part.body.to_s.match(/\s(\d{6})[.]/)[1]

    fill_in "Enter 6 digit code", with: code
    click_on "Verify"

    fill_in "Client ID or Last 4 of SSN/ITIN", with: client.id
    click_on "Continue"
  end

  def complete_intake_through_code_verification
    visit "/en/questions/overview"
    expect(page).to have_selector(".toolbar", text: "GetCTC") # Check for appropriate header
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector(".toolbar", text: "GetCTC")
    click_on I18n.t('general.negative')
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.legal_consent.title'))
    fill_in I18n.t('views.ctc.questions.legal_consent.first_name'), with: "Gary"
    fill_in I18n.t('views.ctc.questions.legal_consent.middle_initial'), with: "H"
    fill_in I18n.t('views.ctc.questions.legal_consent.last_name'), with: "Mango"
    fill_in "ctc_consent_form_primary_birth_date_month", with: "08"
    fill_in "ctc_consent_form_primary_birth_date_day", with: "24"
    fill_in "ctc_consent_form_primary_birth_date_year", with: "1996"
    fill_in I18n.t('views.ctc.questions.legal_consent.ssn'), with: "111-22-8888"
    fill_in I18n.t('views.ctc.questions.legal_consent.ssn_confirmation'), with: "111-22-8888"
    fill_in I18n.t('views.ctc.questions.legal_consent.sms_phone_number'), with: "831-234-5678"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.contact_preference.title'))
    click_on I18n.t('views.ctc.questions.contact_preference.email')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.email_address.title'))
    fill_in I18n.t('views.questions.email_address.email_address'), with: "mango@example.com"
    fill_in I18n.t('views.questions.email_address.email_address_confirmation'), with: "mango@example.com"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("p", text: I18n.t('views.ctc.questions.verification.body').strip)

    perform_enqueued_jobs
    mail = ActionMailer::Base.deliveries.last
    code = mail.html_part.body.to_s.match(/\s(\d{6})[.]/)[1]

    fill_in I18n.t('views.ctc.questions.verification.verification_code_label'), with: "000001"
    click_on I18n.t('general.continue')
    expect(page).to have_content(I18n.t('views.ctc.questions.verification.error_message'))

    fill_in I18n.t('views.ctc.questions.verification.verification_code_label'), with: code
    click_on I18n.t('general.continue')
  end

  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  context "With a client who consented", active_job: true do
    context "As a client logging in twice on CTC questions" do
      let(:hashed_verification_code) { "hashed_verification_code" }
      let(:double_hashed_verification_code) { "double_hashed_verification_code" }
      let(:fake_time) { Time.utc(2021, 2, 6, 0, 0, 0) }

      scenario "accumulating session duration" do
        Timecop.freeze(fake_time) do
          complete_intake_through_code_verification
        end

        client = Client.last
        expect(client.last_sign_in_at).to eq(fake_time)

        Capybara.current_session.reset!

        Timecop.freeze(fake_time) do
          visit Ctc::Questions::Dependents::HadDependentsController.to_path_helper
          authenticate_client(client)
          expect(page).to have_text(I18n.t('views.ctc.questions.dependents.had_dependents.title'))
        end
        expect(client.reload.previous_sessions_active_seconds).to eq(0) # last session occurred in one instant
        expect(client.reload.last_seen_at).to eq(fake_time)

        Timecop.freeze(fake_time + 1.minutes) do
          visit Ctc::Questions::Dependents::HadDependentsController.to_path_helper
        end
        expect(client.reload.last_seen_at).to eq(fake_time + 1.minutes)
        expect(client.reload.previous_sessions_active_seconds).to eq(0) # still w/r/t the previous login
        Capybara.current_session.reset!

        Timecop.freeze(fake_time + 2.minutes) do
          visit Ctc::Questions::Dependents::HadDependentsController.to_path_helper
          authenticate_client(client)
          expect(page).to have_text(I18n.t('views.ctc.questions.dependents.had_dependents.title'))
        end
        expect(client.reload.last_seen_at).to eq(fake_time + 2.minutes)
        expect(client.reload.previous_sessions_active_seconds).to eq(1.minutes)
      end
    end
  end
end
