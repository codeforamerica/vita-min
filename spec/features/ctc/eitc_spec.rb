require "rails_helper"

RSpec.feature "CTC Intake", :flow_explorer_screenshot, active_job: true, requires_default_vita_partners: true do
  include CtcIntakeFeatureHelper

  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
    Flipper.enable(:eitc)
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
    click_on I18n.t('general.negative')

    expect(page).to have_selector(".toolbar", text: "GetCTC")
    within "h1" do
      expect(page.source).to include(I18n.t('views.ctc.questions.income.title', current_tax_year: current_tax_year))
    end
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.file_full_return.title"))
    click_on I18n.t("views.ctc.questions.file_full_return.simplified_btn")

    # Ask about EITC
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.claim_eitc.title'))
    click_on I18n.t("general.affirmative")

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.restrictions.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.already_filed.title', current_tax_year: current_tax_year))
    click_on I18n.t('general.negative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.life_situations.title', current_tax_year: current_tax_year))
    click_on I18n.t('general.negative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.legal_consent.title'))
    fill_in I18n.t('views.ctc.questions.legal_consent.first_name'), with: "Edith"
    fill_in I18n.t('views.ctc.questions.legal_consent.middle_initial'), with: "I"
    fill_in I18n.t('views.ctc.questions.legal_consent.last_name'), with: "Tecumpsa-Calhoun"
    fill_in "ctc_legal_consent_form_primary_birth_date_month", with: "12"
    fill_in "ctc_legal_consent_form_primary_birth_date_day", with: "2"
    fill_in "ctc_legal_consent_form_primary_birth_date_year", with: "1988"
    fill_in I18n.t('views.ctc.questions.legal_consent.ssn'), with: "142-86-1000"
    fill_in I18n.t('views.ctc.questions.legal_consent.ssn_confirmation'), with: "142-86-1000"
    fill_in I18n.t('views.ctc.questions.legal_consent.sms_phone_number'), with: "512=123-1234"
    check "agree_to_privacy_policy"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filed_prior_tax_year.title', prior_tax_year: prior_tax_year))
    choose I18n.t('views.ctc.questions.filed_prior_tax_year.did_not_file', prior_tax_year: prior_tax_year)
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.contact_preference.title'))
    click_on I18n.t('views.ctc.questions.contact_preference.email')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.email_address.title'))
    fill_in I18n.t('views.questions.email_address.email_address'), with: "eitc@example.com"
    fill_in I18n.t('views.questions.email_address.email_address_confirmation'), with: "eitc@example.com"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("p", text: I18n.t('views.ctc.questions.verification.body').strip)

    perform_enqueued_jobs
    mail = ActionMailer::Base.deliveries.last
    code = mail.html_part.body.to_s.match(/\s(\d{6})[.]/)[1]

    fill_in I18n.t('views.ctc.questions.verification.verification_code_label'), with: code
    click_on I18n.t("views.ctc.questions.verification.verify")

    expect(page).to have_selector("h1", text:I18n.t('views.ctc.questions.investment_income.title'))
    expect(page).to have_selector("p", text:I18n.t('views.ctc.questions.investment_income.help_text'))

    click_on "Yes"
    expect(page).to have_selector("h1", text:I18n.t('views.ctc.questions.eitc_offboarding.title'))
    expect(page).to have_selector("p", text:I18n.t('views.ctc.questions.eitc_offboarding.help_text'))
    click_on "Go back" # This will be at the top of your offbvoarding page
    expect(page).to have_selector("h1", text:I18n.t('views.ctc.questions.investment_income.title'))
    click_on "No" # puts you back on the investment income page
    # Dependents page (skips EITC offboarding page)
    expect(page).to have_selector("h1", text:I18n.t('views.ctc.questions.had_dependents.title', current_tax_year: TaxReturn.current_tax_year))
  end

  scenario "a client who lives in Puerto Rico does not see the claim EITC page" do
    visit "/en/questions/overview"
    expect(page).to have_selector(".toolbar", text: "GetCTC") # Check for appropriate header
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.main_home.title', current_tax_year: current_tax_year))
    choose I18n.t('views.ctc.questions.main_home.options.puerto_rico')
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filing_status.title', current_tax_year: current_tax_year))
    click_on I18n.t('general.affirmative')

    expect(page).to have_selector(".toolbar", text: "GetCTC")
    within "h1" do
      expect(page.source).to include(I18n.t('views.ctc.questions.income.title', current_tax_year: current_tax_year))
    end
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.file_full_return.puerto_rico.title"))
    click_on I18n.t("views.ctc.questions.file_full_return.puerto_rico.simplified_btn")

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.restrictions.title'))
    click_on I18n.t('general.continue')
  end

  scenario "a client who is under 24 and has no qualifying children" do
    fill_in_can_use_ctc
    fill_in_eligibility
    fill_in_basic_info(birthdate: 23.years.ago)
    fill_in_spouse_info

    # EITC investment question
    expect(page).to have_selector("h1", text:I18n.t('views.ctc.questions.investment_income.married_title'))
    click_on I18n.t('general.negative')

    # Dependents
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.had_dependents.title', current_tax_year: current_tax_year))
    click_on I18n.t('general.negative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.no_dependents.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_text(I18n.t('views.ctc.questions.no_dependents_advance_ctc_payments.title', current_tax_year: current_tax_year))
    click_on I18n.t('general.negative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.eitc_qualifiers.title'))
    check I18n.t('general.none_of_the_above')
    click_on I18n.t('general.continue')

    # not meeting any of the exceptions disqualifies client
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.eitc_offboarding.title'))

    click_on I18n.t('general.back')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.eitc_qualifiers.title'))
    select I18n.t('views.ctc.questions.eitc_qualifiers.former_foster_youth')

    # meeting an exception qualifies client
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.advance_ctc.title', adv_ctc_estimate: 1800))
  end
end
