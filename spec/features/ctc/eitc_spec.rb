require "rails_helper"

RSpec.feature "CTC Intake", :flow_explorer_screenshot, active_job: true, requires_default_vita_partners: true do
  include CtcIntakeFeatureHelper

  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
    Flipper.enable(:eitc)
  end

  scenario "a client who qualifies for and wants to claim EITC" do
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
    click_on I18n.t('general.negative')

    # no dependents
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.had_dependents.title', current_tax_year: current_tax_year))
    click_on I18n.t('views.ctc.questions.had_dependents.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.no_dependents.title'))
    click_on I18n.t('general.continue')
    expect(page).to have_text(I18n.t('views.ctc.questions.no_dependents_advance_ctc_payments.title', current_tax_year: current_tax_year))
    click_on I18n.t('general.negative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.w2s.title'))
    click_on I18n.t('views.ctc.questions.w2s.add')

    expect(page).to have_text(I18n.t('views.ctc.questions.w2s.employee_info.title'))
    fill_in I18n.t('views.ctc.questions.w2s.employee_info.legal_first_name'), with: 'sam'
    fill_in I18n.t('views.ctc.questions.w2s.employee_info.legal_last_name'), with: 'eagley'
    fill_in I18n.t('views.ctc.questions.w2s.employee_info.employee_ssn'), with: '888-22-3333'
    fill_in I18n.t('views.ctc.questions.w2s.employee_info.confirm_employee_ssn'), with: '888-22-3333'
    fill_in I18n.t('views.ctc.questions.w2s.employee_info.wages_amount'), with: '123.45'
    fill_in I18n.t('views.ctc.questions.w2s.employee_info.federal_income_tax_withheld'), with: '12.01'
    fill_in I18n.t('views.ctc.questions.w2s.employee_info.employee_street_address'), with: '123 Cool St'
    fill_in I18n.t('views.ctc.questions.w2s.employee_info.employee_city'), with: 'City Town'
    select "California", from: I18n.t('views.ctc.questions.w2s.employee_info.employee_state')
    fill_in I18n.t('views.ctc.questions.w2s.employee_info.employee_zip_code'), with: '94110'
    click_on I18n.t('general.continue')

    expect(page).to have_text(I18n.t('views.ctc.questions.w2s.employer_info.title'))
    fill_in I18n.t('views.ctc.questions.w2s.employer_info.employer_ein'), with: '123112222'
    fill_in I18n.t('views.ctc.questions.w2s.employer_info.employer_name'), with: 'lumen inc'
    fill_in I18n.t('views.ctc.questions.w2s.employer_info.employer_street_address'), with: '123 Easy St'
    fill_in I18n.t('views.ctc.questions.w2s.employer_info.employer_city'), with: 'Citytown'
    select "California", from: I18n.t('views.ctc.questions.w2s.employer_info.employer_state')
    fill_in I18n.t('views.ctc.questions.w2s.employer_info.employer_zip_code'), with: '94105'
    select "S", from: I18n.t('views.ctc.questions.w2s.employer_info.standard_or_non_standard_code')
    click_on I18n.t('views.ctc.questions.w2s.employer_info.add')

    expect(page).to have_text(I18n.t('views.ctc.questions.w2s.title'))
    expect(page).to have_text 'lumen inc'

    expect(W2.last.employee_ssn).to eq '888223333'
  end

  scenario "a client who does not qualify for the EITC" do
    fill_in_can_use_ctc
    fill_in_eligibility
    fill_in_basic_info(birthdate: 23.years.ago)
    fill_in_spouse_info

    # EITC investment question
    expect(page).to have_selector("h1", text:I18n.t('views.ctc.questions.investment_income.married_title'))
    click_on I18n.t('general.negative')

    # Client will be disqualified age and having no dependents
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.had_dependents.title', current_tax_year: current_tax_year))
    click_on I18n.t('views.ctc.questions.had_dependents.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.no_dependents.title'))
    click_on I18n.t('general.continue')
    expect(page).to have_text(I18n.t('views.ctc.questions.no_dependents_advance_ctc_payments.title', current_tax_year: current_tax_year))
    click_on I18n.t('general.negative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.eitc_qualifiers.title', current_tax_year: current_tax_year))
    check I18n.t('general.none_of_the_above')
    click_on I18n.t('general.continue')

    # offboarding page
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.eitc_offboarding.title'))
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
end
