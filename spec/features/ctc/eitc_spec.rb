require "rails_helper"

RSpec.feature "CTC Intake", :flow_explorer_screenshot_i18n_friendly, active_job: true, requires_default_vita_partners: true do
  include CtcIntakeFeatureHelper

  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
    allow(Flipper).to receive(:enabled?).with(:eitc).and_return true
  end

  scenario "EITC intake" do
    visit "/en/questions/overview"
    expect(page).to have_selector(".toolbar", text: "GetCTC") # Check for appropriate header
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.main_home.title', current_tax_year: current_tax_year))
    choose I18n.t("views.ctc.questions.main_home.options.fifty_states")
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filing_status.title', current_tax_year: current_tax_year))
    click_on I18n.t('general.affirmative')

    expect(page).to have_selector(".toolbar", text: "GetCTC")
    within "h1" do
      expect(page.source).to include(I18n.t('views.ctc.questions.income.title', current_tax_year: current_tax_year))
    end
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.file_full_return.title"))
    click_on I18n.t("views.ctc.questions.file_full_return.simplified_btn")

    # Ask about EITC
    expect(page).to have_selector("h1", text: "Are you also interested in claiming the Earned Income Tax Credit?")
    click_on I18n.t("general.affirmative")

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.restrictions.title'))
    click_on I18n.t('general.continue')

  end
end
