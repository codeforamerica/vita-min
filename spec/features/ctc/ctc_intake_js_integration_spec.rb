require "rails_helper"

RSpec.feature "CTC Intake Javascript Integrations", :js, active_job: true, requires_default_vita_partners: true do
  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  scenario "we save the timezone and security information for new clients" do
    visit "/en/questions/overview"
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filing_status.title'))
    choose I18n.t('general.filing_status.single')
    click_on I18n.t('general.continue')
    intake = Intake::CtcIntake.last
    expect(intake.timezone).to be_present
    expect(intake.client.efile_security_informations.last.client_system_time).to be_present
    expect(intake.client.efile_security_informations.last.device_id).to be_present
  end
end
