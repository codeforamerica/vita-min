require "rails_helper"

RSpec.feature "sign out during CTC Intake", active_job: true, efile_security_params: true, requires_default_vita_partners: true do
  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  scenario "new client entering ctc intake flow" do
    sign_up
    click_on "Sign out"

    expect(page).to have_text "You've been successfully signed out."
    expect(page).to have_text I18n.t("views.ctc_pages.home.header")
  end

  def sign_up
    visit "/en/questions/overview"
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filing_status.title'))
    choose I18n.t('views.ctc.questions.filing_status.single')
    click_on I18n.t('general.continue')
    click_on I18n.t('general.negative')
    click_on I18n.t("views.ctc.questions.file_full_return.simplified_btn")
    click_on I18n.t('general.negative')
    choose I18n.t('views.ctc.questions.filed_prior_tax_year.did_not_file', prior_tax_year: prior_tax_year)
    click_on "Continue"
    check I18n.t('views.ctc.questions.home.options.fifty_states')
    click_on I18n.t('general.continue')
    click_on I18n.t('general.negative')
    fill_in I18n.t('views.ctc.questions.legal_consent.first_name'), with: "Gary"
    fill_in I18n.t('views.ctc.questions.legal_consent.middle_initial'), with: "H"
    fill_in I18n.t('views.ctc.questions.legal_consent.last_name'), with: "Mango"
    fill_in "ctc_legal_consent_form_primary_birth_date_month", with: "08"
    fill_in "ctc_legal_consent_form_primary_birth_date_day", with: "24"
    fill_in "ctc_legal_consent_form_primary_birth_date_year", with: "1996"
    fill_in I18n.t('views.ctc.questions.legal_consent.ssn'), with: "111-22-8888"
    fill_in I18n.t('views.ctc.questions.legal_consent.ssn_confirmation'), with: "111-22-8888"
    fill_in I18n.t('views.ctc.questions.legal_consent.sms_phone_number'), with: "831-234-5678"
    click_on I18n.t('views.ctc.questions.legal_consent.agree')
    click_on I18n.t('views.ctc.questions.contact_preference.email')
    fill_in I18n.t('views.questions.email_address.email_address'), with: "mango@example.com"
    fill_in I18n.t('views.questions.email_address.email_address_confirmation'), with: "mango@example.com"
    click_on I18n.t('general.continue')
    perform_enqueued_jobs
    mail = ActionMailer::Base.deliveries.last
    code = mail.html_part.body.to_s.match(/\s(\d{6})[.]/)[1]
    fill_in I18n.t('views.ctc.questions.verification.verification_code_label'), with: "000001"
    fill_in I18n.t('views.ctc.questions.verification.verification_code_label'), with: code
    click_on I18n.t("views.ctc.questions.verification.verify")
  end
end
