require "rails_helper"

RSpec.feature "CTC Intake", :flow_explorer_screenshot, active_job: true, requires_default_vita_partners: true do
  include CtcIntakeFeatureHelper

  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
    Flipper.enable(:eitc)
  end

  scenario "a client who qualifies for and wants to claim EITC" do
    fill_in_can_use_ctc(filing_status: "single")
    fill_in_eligibility
    fill_in_basic_info

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.investment_income.title',current_tax_year: current_tax_year))
    click_on I18n.t('general.negative')

    fill_in_no_dependents

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.w2s.title'))
    click_on I18n.t('views.ctc.questions.w2s.dont_add_w2')

    # offboards and skips rest of w2 pages
    expect(page).to have_text(I18n.t("views.ctc.questions.eitc_no_w2_offboarding.title"))
    click_on I18n.t('general.back')

    fill_in_w2("Gary Mango III", filing_status: 'single')

    expect(page).to have_text(I18n.t('views.ctc.questions.w2s.title'))
    expect(page).to have_text 'lumen inc'
    expect(W2.last.employee_ssn).to eq '111228888'

    click_on I18n.t('views.ctc.questions.w2s.delete_this_w2')

    expect(page).to have_text(I18n.t('views.ctc.questions.w2s.title'))
    expect(page).not_to have_text 'lumen inc'

    fill_in_w2("Gary Mango III", filing_status: 'single', delete_instead_of_submit: true)

    expect(page).to have_text(I18n.t('views.ctc.questions.w2s.title'))
    expect(page).not_to have_text 'lumen inc'
  end

  scenario "a MFJ client who qualifies for and wants to claim EITC and enters spouse W2" do
    fill_in_can_use_ctc(filing_status: "married_filing_jointly")
    fill_in_eligibility
    fill_in_basic_info
    fill_in_spouse_info

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.investment_income.married_title',current_tax_year: current_tax_year))
    click_on I18n.t('general.negative')

    fill_in_no_dependents

    fill_in_w2("Peter Pepper", filing_status: 'married_filing_jointly')

    expect(W2.last.employee_ssn).to eq '222334444'
  end

  scenario "a client who does not qualify for the EITC" do
    fill_in_can_use_ctc
    fill_in_eligibility
    fill_in_basic_info(birthdate: 23.years.ago)
    fill_in_spouse_info(birthdate: 23.years.ago)

    # EITC investment question
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.investment_income.married_title',current_tax_year: current_tax_year))
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

    # off-boarding page
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.eitc_offboarding.title'))
    click_on I18n.t("general.continue")

    # Continue with stimulus/RRC flow
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_payments.title', third_stimulus_amount: "$2,800"))
  end

  scenario "a client who said they have W-2 income within EITC but adds no W-2s so is offboarded from EITC" do
    fill_in_can_use_ctc(filing_status: "married_filing_jointly")
    fill_in_eligibility
    fill_in_basic_info
    fill_in_spouse_info

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.investment_income.married_title'))
    click_on I18n.t('general.negative')

    fill_in_dependents

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.w2s.title'))
    click_on I18n.t("views.ctc.questions.w2s.dont_add_w2")
    expect(page).to have_selector("p", text: I18n.t("views.ctc.questions.eitc_no_w2_offboarding.help_text"))
    click_on I18n.t("views.ctc.questions.eitc_no_w2_offboarding.buttons.continue_without")
    fill_in_advance_child_tax_credit
    fill_in_recovery_rebate_credit
    fill_in_bank_info
    fill_in_ip_pins
    fill_in_review(filing_status: "married_filing_jointly")
    expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.home.title"))
  end

  scenario "a client who has W-2 income within EITC but doesn't qualify due to additional income" do
    fill_in_can_use_ctc(filing_status: "married_filing_jointly")
    fill_in_eligibility
    fill_in_basic_info
    fill_in_spouse_info

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.investment_income.married_title',current_tax_year: current_tax_year))
    click_on I18n.t('general.negative')

    fill_in_no_dependents
    fill_in_w2('Peter Pepper', filing_status: 'married_filing_jointly', wages: 16_000)
    click_on I18n.t("views.ctc.questions.w2s.done_adding")

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.non_w2_income.title', count: 2, additional_income_amount: '$1,550'))
    click_on I18n.t("general.affirmative")

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.eitc_income_offboarding.title', count: 2))
  end

  scenario "a client who has too much W-2 income for simplified filing" do
    fill_in_can_use_ctc(filing_status: "married_filing_jointly")
    fill_in_eligibility
    fill_in_basic_info
    fill_in_spouse_info

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.investment_income.married_title',current_tax_year: current_tax_year))
    click_on I18n.t('general.negative')

    fill_in_no_dependents
    fill_in_w2('Peter Pepper', filing_status: 'married_filing_jointly', wages: 26_000)
    click_on I18n.t("views.ctc.questions.w2s.done_adding")

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.simplified_filing_income_offboarding.title', count: 2))
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
       expect(page.source).to include(I18n.t('views.ctc.questions.income.title.other', current_tax_year: current_tax_year))
    end
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.file_full_return.puerto_rico.title"))
    click_on I18n.t("views.ctc.questions.file_full_return.puerto_rico.simplified_btn")

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.restrictions.title'))
    click_on I18n.t('general.continue')
  end
end
