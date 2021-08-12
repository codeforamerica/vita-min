require "rails_helper"

RSpec.feature "during CTC intake clients see a warning on pages that require JS when they have it disabled" do
  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  scenario "client visits js required pages with javascript turned on", js: true do
    visit "/en/questions/legal-consent"
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.legal_consent.title'))
    expect(page).not_to have_text "Please enable Javascript in your browser or use a different browser."

    create_client_and_sign_in

    visit "/en/questions/spouse-info"
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.spouse_info.title'))
    expect(page).not_to have_text "Please enable Javascript in your browser or use a different browser."

    # visit "/en/questions/confirm-legal"
    # expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.confirm_legal.title"))
    # expect(page).not_to have_text "Please enable Javascript in your browser or use a different browser."
  end

  scenario "client visits js required pages with javascript turned off" do
    visit "/en/questions/legal-consent"
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.legal_consent.title'))
    expect(page).to have_text "Please enable Javascript in your browser or use a different browser."

    create_client_and_sign_in

    visit "/en/questions/spouse-info"
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.spouse_info.title'))
    expect(page).to have_text "Please enable Javascript in your browser or use a different browser."

    # visit "/en/questions/confirm-legal"
    # expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.confirm_legal.title"))
    # expect(page).to have_text "Please enable Javascript in your browser or use a different browser."
  end

  def create_client_and_sign_in
    fill_in I18n.t('views.ctc.questions.legal_consent.first_name'), with: "Gary"
    fill_in I18n.t('views.ctc.questions.legal_consent.middle_initial'), with: "H"
    fill_in I18n.t('views.ctc.questions.legal_consent.last_name'), with: "Mango"
    select "III", from: I18n.t('views.ctc.questions.legal_consent.suffix')
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

    expect(page).to have_selector("p", text: I18n.t('views.ctc.questions.verification.body').strip)

    perform_enqueued_jobs
    mail = ActionMailer::Base.deliveries.last
    code = mail.html_part.body.to_s.match(/\s(\d{6})[.]/)[1]

    fill_in I18n.t('views.ctc.questions.verification.verification_code_label'), with: code
    click_on I18n.t("views.ctc.questions.verification.verify")
  end
end
