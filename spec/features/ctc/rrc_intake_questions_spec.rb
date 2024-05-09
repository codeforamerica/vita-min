require "rails_helper"

RSpec.feature "CTC Intake", :flow_explorer_screenshot, active_job: true, requires_default_vita_partners: true do
  include CtcIntakeFeatureHelper

  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  scenario "new married filing jointly client doing ctc intake" do
    fill_in_can_use_ctc(filing_status: "married_filing_jointly")
    fill_in_eligibility
    fill_in_basic_info
    fill_in_spouse_info
    fill_in_dependents
    fill_in_advance_child_tax_credit
    fill_in_recovery_rebate_credit
    fill_in_bank_info
    fill_in_ip_pins
    fill_in_review

    # =========== PORTAL ===========
    expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.home.title"))
  end

  scenario "new head of household client doing ctc intake" do
    fill_in_can_use_ctc(filing_status: "single")
    fill_in_eligibility
    fill_in_basic_info
    fill_in_dependents(head_of_household: true)
    fill_in_advance_child_tax_credit
    fill_in_recovery_rebate_credit(third_stimulus_amount: "$2,800")
    fill_in_bank_info
    fill_in_ip_pins
    fill_in_review(filing_status: "single")

    # =========== PORTAL ===========
    expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.home.title"))
    expect(Intake::CtcIntake.last.default_tax_return.filing_status).to eq 'single'
  end

  scenario "client who has filed in 2019" do
    # =========== BASIC INFO ===========
    visit "/en/questions/overview"
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.main_home.title', current_tax_year: MultiTenantService.new(:ctc).current_tax_year))
    choose I18n.t('views.ctc.questions.main_home.options.fifty_states')
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filing_status.title', current_tax_year: MultiTenantService.new(:ctc).current_tax_year))
    click_on I18n.t('general.affirmative')

    expect(page).to have_text(I18n.t("views.ctc.questions.income_qualifier.subtitle"))
    click_on I18n.t('general.affirmative')
    within "h1" do
      expect(page.source).to include(I18n.t('views.ctc.questions.income.title.other', current_tax_year: MultiTenantService.new(:ctc).current_tax_year))
    end
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.file_full_return.title_eitc"))
    click_on I18n.t("views.ctc.questions.file_full_return.simplified_btn")
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.claim_eitc.title'))
    click_on I18n.t('views.ctc.questions.claim_eitc.buttons.dont_claim')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.restrictions.title'))
    click_on I18n.t('general.continue')

    # =========== ELIGIBILITY ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.already_filed.title', current_tax_year: MultiTenantService.new(:ctc).current_tax_year))
    click_on I18n.t('general.negative')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.life_situations.title', current_tax_year: MultiTenantService.new(:ctc).current_tax_year))
    click_on I18n.t('general.negative')

    # =========== BASIC INFO ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.legal_consent.title'))
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
    check I18n.t('views.ctc.questions.legal_consent.primary_active_armed_forces', current_tax_year: MultiTenantService.new(:ctc).current_tax_year)
    check "agree_to_privacy_policy"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filed_prior_tax_year.title', prior_tax_year: prior_tax_year))
    choose I18n.t('views.ctc.questions.filed_prior_tax_year.filed_full', prior_tax_year: prior_tax_year)
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.prior_tax_year_agi.title', prior_tax_year: prior_tax_year))
    fill_in I18n.t('views.ctc.questions.prior_tax_year_agi.label', prior_tax_year: prior_tax_year), with: '$12,340'
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

    fill_in I18n.t('views.ctc.questions.verification.verification_code_label'), with: "000001"
    click_on I18n.t("views.ctc.questions.verification.verify")
    expect(page).to have_content(I18n.t('views.ctc.questions.verification.error_message'))

    fill_in I18n.t('views.ctc.questions.verification.verification_code_label'), with: code
    click_on I18n.t("views.ctc.questions.verification.verify")

    # =========== SPOUSE INFO ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.spouse_info.title'))
    fill_in I18n.t('views.ctc.questions.spouse_info.spouse_first_name'), with: "Peter"
    fill_in I18n.t('views.ctc.questions.spouse_info.spouse_middle_initial'), with: "P"
    fill_in I18n.t('views.ctc.questions.spouse_info.spouse_last_name'), with: "Pepper"
    fill_in "ctc_spouse_info_form[spouse_birth_date_month]", with: "01"
    fill_in "ctc_spouse_info_form[spouse_birth_date_day]", with: "11"
    fill_in "ctc_spouse_info_form[spouse_birth_date_year]", with: "1995"
    select I18n.t('general.tin.ssn')
    fill_in I18n.t('views.ctc.questions.spouse_info.spouse_ssn_itin'), with: "222-33-4444"
    fill_in I18n.t('views.ctc.questions.spouse_info.spouse_ssn_itin_confirmation'), with: "222-33-4444"
    click_on I18n.t('views.ctc.questions.spouse_info.save_button')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.spouse_filed_prior_tax_year.title', prior_tax_year: prior_tax_year, spouse_first_name: "Peter"))
    choose I18n.t('views.ctc.questions.spouse_filed_prior_tax_year.filed_full_separate')
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.spouse_prior_tax_year_agi.title', prior_tax_year: prior_tax_year, spouse_first_name: "Peter"))
    fill_in I18n.t('views.ctc.questions.prior_tax_year_agi.label', prior_tax_year: prior_tax_year), with: '4,567'
    click_on I18n.t('general.continue')

    click_on I18n.t('general.continue')

    # No dependents
    click_on I18n.t('views.ctc.questions.had_dependents.continue')

    # No Advance CTC
    click_on I18n.t('general.continue')
    click_on I18n.t('general.negative')

    # =========== RECOVERY REBATE CREDIT ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_payments.title', third_stimulus_amount: "$2,800"))
    click_on I18n.t('views.ctc.questions.stimulus_payments.different_amount')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_three.title'))
    fill_in I18n.t('views.ctc.questions.stimulus_three.how_much'), with: "1800"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_owed.title'))
    click_on I18n.t('general.continue')

    # =========== BANK AND MAILING INFO ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.refund_payment.title'))
    choose I18n.t('views.questions.refund_payment.direct_deposit')
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.portal.bank_account.title'))
    fill_in I18n.t('views.questions.bank_details.bank_name'), with: "Bank of Two Melons"
    choose I18n.t('views.questions.bank_details.account_type.checking')
    check I18n.t('views.ctc.questions.direct_deposit.my_bank_account.label')
    fill_in I18n.t('views.ctc.questions.routing_number.routing_number'), with: "019456124"
    fill_in I18n.t('views.ctc.questions.routing_number.routing_number_confirmation'), with: "019456124"
    fill_in I18n.t('views.ctc.questions.account_number.account_number'), with: "123456789"
    fill_in I18n.t('views.ctc.questions.account_number.account_number_confirmation'), with: "123456789"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_bank_account.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.mailing_address.title'))
    fill_in I18n.t('views.questions.mailing_address.street_address'), with: "26 William Street"
    fill_in I18n.t('views.questions.mailing_address.street_address2'), with: "Apt 1234"
    fill_in I18n.t('views.questions.mailing_address.city'), with: "Bel Air"
    select "California", from: I18n.t('views.questions.mailing_address.state')
    fill_in I18n.t('views.questions.mailing_address.zip_code'), with: 90001
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.confirm_mailing_address.title"))
    click_on I18n.t('general.confirm')

    # =========== IP PINs ===========
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.ip_pin.title'))
    check I18n.t('general.none_of_the_above')
    click_on I18n.t('general.continue')

    # =========== REVIEW ===========
    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.confirm_information.title"))

    expect(page).to have_selector("h2", text: I18n.t("views.ctc.questions.confirm_information.your_information"))
    within ".primary-prior-year-agi" do
      expect(page).to have_selector("div", text: "$12,340")
      click_on I18n.t('general.edit').downcase
    end

    fill_in 'ctc_prior_tax_year_agi_form_primary_prior_year_agi_amount', with: '12345'
    click_on I18n.t('general.save')

    within ".primary-prior-year-agi" do
      expect(page).to have_selector("div", text: "$12,345")
    end

    within ".spouse-prior-year-agi" do
      expect(page).to have_selector("div", text: "$4,567")
      click_on I18n.t('general.edit').downcase
    end

    fill_in 'ctc_spouse_prior_tax_year_agi_form_spouse_prior_year_agi_amount', with: '4321'
    click_on I18n.t('general.save')

    within ".spouse-prior-year-agi" do
      expect(page).to have_selector("div", text: "$4,321")
    end
  end

  it "allows the basic filer info to be edited after it was created" do
    complete_intake_through_code_verification
    expect(Intake.count).to eq(1)

    visit "/en/questions/legal-consent"

    new_birth_date = Date.parse('1967-06-09')
    fill_in "ctc_legal_consent_form_primary_birth_date_month", with: new_birth_date.month
    fill_in "ctc_legal_consent_form_primary_birth_date_day", with: new_birth_date.day
    fill_in "ctc_legal_consent_form_primary_birth_date_year", with: new_birth_date.year
    check "agree_to_privacy_policy"
    click_on I18n.t('general.continue')

    expect(Intake.count).to eq(1)
    expect(Intake.last.primary_birth_date).to eq(new_birth_date)
  end
end
