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

    expect(page).to have_selector("h1", text:I18n.t('views.ctc.questions.investment_income.title'))
    click_on I18n.t('general.negative')

    fill_in_no_dependents

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.w2s.title'))
    click_on I18n.t('views.ctc.questions.w2s.dont_add_w2')

    # skips rest of w2 pages
    expect(page).to have_text(I18n.t('views.ctc.questions.stimulus_payments.title', third_stimulus_amount: "$1,400"))

    click_on I18n.t('general.back')

    fill_in_w2

    expect(page).to have_text(I18n.t('views.ctc.questions.w2s.title'))
    expect(page).to have_text 'lumen inc'
    expect(W2.last.employee_ssn).to eq '888223333'
  end

  scenario "a client who does not qualify for the EITC" do
    fill_in_can_use_ctc
    fill_in_eligibility
    fill_in_basic_info(birthdate: 23.years.ago)
    fill_in_spouse_info(birthdate: 23.years.ago)

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
       expect(page.source).to include(I18n.t('views.ctc.questions.income.title.other', current_tax_year: current_tax_year))
    end
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.file_full_return.puerto_rico.title"))
    click_on I18n.t("views.ctc.questions.file_full_return.puerto_rico.simplified_btn")

    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.restrictions.title'))
    click_on I18n.t('general.continue')
  end
end
