require "rails_helper"

RSpec.feature "CTC Intake Javascript Integrations", :js, active_job: true do
  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  scenario "we save the timezone for new clients" do
    visit "/en/questions/overview"
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector(".toolbar", text: "GetCTC")
    click_on I18n.t('general.negative')
    intake = Intake::CtcIntake.last
    expect(intake.timezone).to be_present
  end
end
