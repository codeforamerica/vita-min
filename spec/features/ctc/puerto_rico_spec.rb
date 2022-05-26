require "rails_helper"

RSpec.feature "Puerto Rico", :flow_explorer_screenshot_i18n_friendly, active_job: true, requires_default_vita_partners: true do
  include CtcIntakeFeatureHelper
  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end
  context "when we have not launched puerto rico intake" do
    before do
      allow(Flipper).to receive(:enabled?).and_return false
    end

    scenario "we do not allow those who reside in puerto rico to complete intake" do
      visit "/en/questions/overview"
      expect(page).to have_selector(".toolbar", text: "GetCTC") # Check for appropriate header
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title'))
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.main_home.title', current_tax_year: current_tax_year))
      choose I18n.t('views.ctc.questions.main_home.options.puerto_rico')
      click_on I18n.t('general.continue')
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.offboarding.puerto_rico_sign_up.title'))
    end
  end
  
  context "when the puerto rico intake has launched" do
    before do
      allow(Flipper).to receive(:enabled?).and_return true
    end

    scenario "puerto rico intake" do
      fill_in_can_use_ctc(filing_status: "married_filing_jointly", home_location: "puerto_rico")
      fill_in_eligibility
      fill_in_basic_info
      fill_in_spouse_info
      # modified dependent flow
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.had_dependents.title', current_tax_year: current_tax_year))
      click_on "Yes"

      fill_in_qualifying_child_age_5
      # check they dont appear on summary page
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_dependents.title'))
      expect(page).not_to have_selector(".review-box__title", text: I18n.t("views.ctc.questions.confirm_dependents.qualifying_for_both"))
      expect(page).not_to have_selector(".review-box__title", text: I18n.t("views.ctc.questions.confirm_dependents.qualifying_for_other_credits"))
      expect(page).to have_selector(".review-box__title", text: I18n.t("views.ctc.questions.confirm_dependents.qualifying_for_ctc"))
      click_on I18n.t('views.ctc.questions.confirm_dependents.done_adding')

      fill_in_advance_child_tax_credit
      # Skips RRC Questions
      fill_in_bank_info
      fill_in_ip_pins
      fill_in_review(home_location: "puerto_rico")
    end
  end
end
