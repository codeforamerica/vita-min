require "rails_helper"

RSpec.feature "Session duration", requires_default_vita_partners: true do
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
          expect(page).to have_text(I18n.t('views.ctc.questions.dependents.had_dependents.title', current_tax_year: current_tax_year))
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
          expect(page).to have_text(I18n.t('views.ctc.questions.dependents.had_dependents.title', current_tax_year: current_tax_year))
        end
        expect(client.reload.last_seen_at).to eq(fake_time + 2.minutes)
        expect(client.reload.previous_sessions_active_seconds).to eq(1.minutes)
      end
    end
  end
end
