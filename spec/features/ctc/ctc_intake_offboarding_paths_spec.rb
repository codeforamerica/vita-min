require "rails_helper"

RSpec.feature "CTC Intake", :flow_explorer_screenshot, active_job: true, requires_default_vita_partners: true do
  include CtcIntakeFeatureHelper

  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  context "offboarding duplicate clients" do
    before do
      # create duplicated intake
      create(:ctc_intake,
             primary_consented_to_service: "yes",
             primary_ssn: "111-22-8888",
             email_address: "mango@example.com",
             email_notification_opt_in: "yes",
             email_address_verified_at: DateTime.now
           )
    end

    scenario "new client entering ctc intake flow" do
      # =========== BASIC INFO ===========
      visit "/en/questions/overview"
      expect(page).to have_selector(".toolbar", text: "GetCTC") # Check for appropriate header
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title'))
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.main_home.title', current_tax_year: current_tax_year))
      choose I18n.t('views.ctc.questions.main_home.options.foreign_address')
      click_on I18n.t('general.continue')
      expect(page).to have_selector("h1", text:  I18n.t('views.ctc.questions.use_gyr.title'))
      click_on I18n.t('general.back')
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.main_home.title', current_tax_year: current_tax_year))
      choose I18n.t('views.ctc.questions.main_home.options.fifty_states')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filing_status.title'))
      click_on I18n.t('general.negative')


      expect(page).to have_selector(".toolbar", text: "GetCTC")
      within "h1" do
        expect(page.source).to include(I18n.t('views.ctc.questions.income.title.one', current_tax_year: current_tax_year))
      end
      click_on I18n.t('general.continue')
      click_on I18n.t("views.ctc.questions.file_full_return.simplified_btn")
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.restrictions.title'))
      click_on I18n.t('general.continue')

      # =========== ELIGIBILITY ===========
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.already_filed.title', current_tax_year: current_tax_year))
      click_on I18n.t('general.negative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.life_situations.title', current_tax_year: current_tax_year))
      click_on I18n.t('general.negative')

      # =========== BASIC INFO ===========
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.legal_consent.title'))
      fill_in I18n.t('views.ctc.questions.legal_consent.first_name'), with: "Gary"
      fill_in I18n.t('views.ctc.questions.legal_consent.middle_initial'), with: "H"
      fill_in I18n.t('views.ctc.questions.legal_consent.last_name'), with: "Mango"
      fill_in "ctc_legal_consent_form_primary_birth_date_month", with: "08"
      fill_in "ctc_legal_consent_form_primary_birth_date_day", with: "24"
      fill_in "ctc_legal_consent_form_primary_birth_date_year", with: "1996"
      fill_in I18n.t('views.ctc.questions.legal_consent.ssn'), with: "111-22-8888"
      fill_in I18n.t('views.ctc.questions.legal_consent.ssn_confirmation'), with: "111-22-8888"
      fill_in I18n.t('views.ctc.questions.legal_consent.sms_phone_number'), with: "831-234-5678"
      check "agree_to_privacy_policy"
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t("views.questions.returning_client.title"))

      within "main" do
        click_on I18n.t("general.sign_in")
      end

      expect(page).to have_selector("h1", text: I18n.t("portal.client_logins.new.title"))
    end
  end

  context "offboarding people with no dependents who received advance ctc" do
    before do
      fill_in_can_use_ctc(filing_status: "married_filing_jointly")
      fill_in_eligibility
      fill_in_basic_info
      fill_in_spouse_info
    end

    scenario "client can file with GYR" do
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.had_dependents.title', current_tax_year: current_tax_year))
      click_on I18n.t('views.ctc.questions.had_dependents.continue')

      expect(page).to have_text(I18n.t('views.ctc.questions.no_dependents.title'))
      click_on I18n.t('general.continue')

      expect(page).to have_text(I18n.t('views.ctc.questions.no_dependents_advance_ctc_payments.title', current_tax_year: current_tax_year))
      click_on I18n.t("general.affirmative")

      expect(page).to have_text(I18n.t('views.ctc.offboarding.actc_without_dependents.title'))

      click_on I18n.t("views.ctc.offboarding.actc_without_dependents.file_with_gyr")

      expect(SystemNote.last.body).to include "Client clicked File with GetYourRefund button on"
    end

    scenario "client can add more dependents to continue CTC" do
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.had_dependents.title', current_tax_year: current_tax_year))
      click_on I18n.t('views.ctc.questions.had_dependents.continue')

      expect(page).to have_text(I18n.t('views.ctc.questions.no_dependents.title'))

      click_on I18n.t('general.continue')

      expect(page).to have_text(I18n.t('views.ctc.questions.no_dependents_advance_ctc_payments.title', current_tax_year: current_tax_year))

      click_on I18n.t("general.affirmative")

      expect(page).to have_text(I18n.t('views.ctc.offboarding.actc_without_dependents.title'))

      click_on I18n.t('views.ctc.offboarding.actc_without_dependents.add_more_dependents')

      expect(page).to have_text(I18n.t('views.ctc.questions.dependents.info.title'))
    end

    scenario "client who did not receive advance ctc is not offboarded" do
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.had_dependents.title', current_tax_year: current_tax_year))
      click_on I18n.t('views.ctc.questions.had_dependents.continue')

      expect(page).to have_text(I18n.t('views.ctc.questions.no_dependents.title'))

      click_on I18n.t('general.continue')

      expect(page).to have_text(I18n.t('views.ctc.questions.no_dependents_advance_ctc_payments.title', current_tax_year: current_tax_year))

      click_on I18n.t("general.negative")

      expect(page).to have_text(I18n.t('views.ctc.questions.stimulus_payments.title', third_stimulus_amount: '$2,800'))
    end

    scenario "people who remove their last dependent are sent into the offboarding flow" do
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.had_dependents.title', current_tax_year: current_tax_year))

      click_on I18n.t('views.ctc.questions.had_dependents.add')

      dependent_birth_year = 5.years.ago.year

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.info.title'))
      fill_in I18n.t('views.ctc.questions.dependents.info.first_name'), with: "Jessie"
      fill_in I18n.t('views.ctc.questions.dependents.info.middle_initial'), with: "M"
      fill_in I18n.t('views.ctc.questions.dependents.info.last_name'), with: "Pepper"
      fill_in "ctc_dependents_info_form[birth_date_month]", with: "01"
      fill_in "ctc_dependents_info_form[birth_date_day]", with: "11"
      fill_in "ctc_dependents_info_form[birth_date_year]", with: dependent_birth_year
      select I18n.t('general.dependent_relationships.daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin'), with: "222-33-4445"
      fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin_confirmation'), with: "222-33-4445"

      click_on I18n.t('general.continue')

      # Skips qualifiers page because the dependent is only 5

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_expenses.title', name: 'Jessie', current_tax_year: TaxReturn.current_tax_year))
      click_on I18n.t('general.negative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_residence.title', name: 'Jessie', current_tax_year: current_tax_year))
      select I18n.t("views.ctc.questions.dependents.child_residence.select_options.six_to_seven")
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_can_be_claimed_by_other.title', name: 'Jessie'))
      click_on I18n.t('general.affirmative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_dependents.title'))
      expect(page).to have_content("Jessie M Pepper")
      expect(page).to have_selector("div", text: "#{I18n.t('views.ctc.questions.confirm_dependents.birthday')}: 1/11/#{dependent_birth_year}")

      click_on I18n.t('general.edit').downcase

      click_on I18n.t('views.ctc.questions.dependents.tin.remove_person')

      click_on I18n.t('views.ctc.questions.dependents.remove_dependent.remove_button')

      click_on I18n.t('views.ctc.questions.confirm_dependents.done_adding')

      expect(page).to have_text(I18n.t('views.ctc.questions.no_dependents.title'))
    end
  end
end
