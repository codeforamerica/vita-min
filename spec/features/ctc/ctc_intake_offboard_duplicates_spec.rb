require "rails_helper"

RSpec.feature "CTC Intake", :flow_explorer_screenshot_i18n_friendly, active_job: true do
  include FeatureTestHelpers

  before do
    # create duplicated intake
    create(:ctc_intake, email_address: "mango@example.com", email_notification_opt_in: "yes", email_address_verified_at: DateTime.now)
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  scenario "new client entering ctc intake flow" do
    # =========== BASIC INFO ===========
    visit "/en/questions/overview"
    expect(page).to have_selector(".toolbar", text: "GetCTC") # Check for appropriate header
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector(".toolbar", text: "GetCTC")
    within "h1" do
      expect(page.source).to include(I18n.t('views.ctc.questions.income.title', tax_year: 2020))
    end
    click_on I18n.t('general.negative')
    click_on I18n.t("views.ctc.questions.file_full_return.simplified_btn")

    # =========== ELIGIBILITY ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.already_filed.title'))
    click_on I18n.t('general.negative')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filed_prior_tax_year.title', prior_tax_year: Rails.application.config.current_tax_year - 1))
    choose I18n.t('views.ctc.questions.filed_prior_tax_year.did_not_file', prior_tax_year: Rails.application.config.current_tax_year - 1)
    click_on "Continue"
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.home.title'))
    check I18n.t('views.ctc.questions.home.options.fifty_states')
    check I18n.t('views.ctc.questions.home.options.foreign_address')
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text:  I18n.t('views.ctc.questions.use_gyr.title'))
    click_on I18n.t('general.back')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.home.title'))
    check I18n.t('views.ctc.questions.home.options.fifty_states')
    check I18n.t('views.ctc.questions.home.options.military_facility')
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.life_situations.title'))
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
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.contact_preference.title'))
    click_on I18n.t('views.ctc.questions.contact_preference.email')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.email_address.title'))
    fill_in I18n.t('views.questions.email_address.email_address'), with: "mango@example.com"
    fill_in I18n.t('views.questions.email_address.email_address_confirmation'), with: "mango@example.com"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t("views.questions.returning_client.title"))

    within "main" do
      click_on I18n.t("general.sign_in")
    end

    expect(page).to have_selector("h1", text: I18n.t("portal.client_logins.new.title"))
  end
end
