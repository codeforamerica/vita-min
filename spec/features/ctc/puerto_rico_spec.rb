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

    scenario "puerto rico landing page" do
      visit "/puertorico"
      expect(page).to have_content(I18n.t('views.ctc_pages.puerto_rico.title', locale: :es))
      within ".ctc-home" do
        click_on I18n.t('views.ctc_pages.home.get_started', locale: :es)
      end
      expect(page).to have_content(I18n.t('views.ctc.questions.overview.title', locale: :es))
    end

    scenario "puerto rico intake" do
      fill_in_can_use_ctc(filing_status: "married_filing_jointly", home_location: "puerto_rico")
      fill_in_eligibility(home_location: "puerto_rico")
      fill_in_basic_info(home_location: "puerto_rico")
      fill_in_spouse_info
      # modified dependent flow
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.had_dependents.title', current_tax_year: current_tax_year))
      click_on "Yes"

      fill_in_qualifying_child_age_5
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_dependents.title'))
      expect(page).not_to have_selector(".review-box__title", text: I18n.t("views.ctc.questions.confirm_dependents.qualifying_for_both"))
      expect(page).not_to have_selector(".review-box__title", text: I18n.t("views.ctc.questions.confirm_dependents.qualifying_for_other_credits"))
      expect(page).to have_selector(".review-box__title", text: I18n.t("views.ctc.questions.confirm_dependents.qualifying_for_ctc"))
      expect(page).to have_text "Jessie M Pepper"
      # This dependent qualifies
      click_on I18n.t('views.ctc.questions.confirm_dependents.add_a_dependent')

      # Offboard dependent because of birthday
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.info.title'))
      fill_in I18n.t('views.ctc.questions.dependents.info.first_name'), with: "Melanie"
      fill_in I18n.t('views.ctc.questions.dependents.info.middle_initial'), with: "M"
      fill_in I18n.t('views.ctc.questions.dependents.info.last_name'), with: "Pepper"
      fill_in "ctc_dependents_info_form[birth_date_month]", with: "11"
      fill_in "ctc_dependents_info_form[birth_date_day]", with: "01"
      fill_in "ctc_dependents_info_form[birth_date_year]", with: 2000
      select "Social Security Number (SSN)"
      select I18n.t('general.dependent_relationships.daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin'), with: "222-33-4445"
      fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin_confirmation', name: "Jessie"), with: "222-33-4445"
      click_on "Continue"

      expect(page).to have_selector("h1", text: "You can not claim benefits for Melanie. Would you like to add anyone else?")
      click_on "Yes"

      # Offboard because of tin type
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.info.title'))
      fill_in I18n.t('views.ctc.questions.dependents.info.first_name'), with: "Groucho"
      fill_in I18n.t('views.ctc.questions.dependents.info.middle_initial'), with: "M"
      fill_in I18n.t('views.ctc.questions.dependents.info.last_name'), with: "Pepper"
      fill_in "ctc_dependents_info_form[birth_date_month]", with: "11"
      fill_in "ctc_dependents_info_form[birth_date_day]", with: "01"
      fill_in "ctc_dependents_info_form[birth_date_year]", with: 2019
      select "Social Security Number (SSN)"
      select I18n.t('general.dependent_relationships.daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin'), with: "222-33-4445"
      fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin_confirmation', name: "Jessie"), with: "222-33-4445"
      check I18n.t("views.ctc.shared.ssn_not_valid_for_employment")
      click_on "Continue"

      expect(page).to have_selector("h1", text: "You can not claim benefits for Groucho. Would you like to add anyone else?")
      click_on "No, continue"
      click_on I18n.t('views.ctc.questions.confirm_dependents.done_adding')
      fill_in_advance_child_tax_credit
      # Skips RRC Questions
      fill_in_bank_info
      fill_in_ip_pins
      fill_in_review(home_location: "puerto_rico")
    end

    scenario "puerto rico with no qualifying dependents" do
      fill_in_can_use_ctc(filing_status: "married_filing_jointly", home_location: "puerto_rico")
      fill_in_eligibility(home_location: "puerto_rico")
      fill_in_basic_info(home_location: "puerto_rico")
      fill_in_spouse_info
      # modified dependent flow
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.had_dependents.title', current_tax_year: current_tax_year))
      click_on "Yes"

      # Offboard dependent because of birthday
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.info.title'))
      fill_in I18n.t('views.ctc.questions.dependents.info.first_name'), with: "Melanie"
      fill_in I18n.t('views.ctc.questions.dependents.info.middle_initial'), with: "M"
      fill_in I18n.t('views.ctc.questions.dependents.info.last_name'), with: "Pepper"
      fill_in "ctc_dependents_info_form[birth_date_month]", with: "11"
      fill_in "ctc_dependents_info_form[birth_date_day]", with: "01"
      fill_in "ctc_dependents_info_form[birth_date_year]", with: 2000
      select "Social Security Number (SSN)"
      select I18n.t('general.dependent_relationships.daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin'), with: "222-33-4445"
      fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin_confirmation', name: "Jessie"), with: "222-33-4445"
      click_on "Continue"

      expect(page).to have_selector("h1", text: "You can not claim benefits for Melanie. Would you like to add anyone else?")
      click_on "No, continue"

      expect(page).to have_selector("h1", text: "You will not receive the Child Tax Credit")
    end
  end
end
