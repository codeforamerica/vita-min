require "rails_helper"

RSpec.feature "CTC Intake Javascript Integrations", :js, active_job: true do
  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  scenario "we save the timezone for new clients" do
    visit "/en/questions/legal_consent"
    fill_in "Legal first name", with: "Gary"
    fill_in "Legal last name", with: "Mango"
    fill_in "ctc_legal_consent_form_primary_birth_date_month", with: "08"
    fill_in "ctc_legal_consent_form_primary_birth_date_day", with: "24"
    fill_in "ctc_legal_consent_form_primary_birth_date_year", with: "1996"
    fill_in "SSN or ITIN", with: "111-22-8888"
    fill_in "Confirm SSN or ITIN", with: "111-22-8888"
    fill_in "Phone number", with: "831-234-5678"
    click_on "Continue"

    intake = Intake::CtcIntake.last
    expect(intake.timezone).to be_present
  end
end
