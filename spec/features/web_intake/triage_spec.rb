require "rails_helper"

RSpec.feature "client is not eligible for VITA services", :flow_explorer_screenshot do
  scenario "client's income is over the income limit" do
    visit "/en/questions/welcome"

    expect(page).to have_selector("h1", text: I18n.t('views.questions.welcome.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('questions.triage_income_level.edit.title').split("\n").first)
    choose I18n.t('questions.triage_income_level.edit.levels.hh_over_73000')
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('questions.triage_do_not_qualify.edit.title'))
  end

  scenario "client's income is eligible for DIY but not full service" do
    visit "/en/questions/welcome"

    expect(page).to have_selector("h1", text: I18n.t('views.questions.welcome.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('questions.triage_income_level.edit.title').split("\n").first)
    choose I18n.t('questions.triage_income_level.edit.levels.hh_66000_to_73000')
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('questions.triage_referral.edit.title'))
  end

  scenario "client does not have any documents and needs help" do
    visit "/en/questions/welcome"

    expect(page).to have_selector("h1", text: I18n.t('views.questions.welcome.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('questions.triage_income_level.edit.title').split("\n").first)
    choose I18n.t('questions.triage_income_level.edit.levels.zero')
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('questions.triage_start_ids.edit.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('questions.triage_id_type.edit.title'))
    choose I18n.t("questions.triage_id_type.edit.ssn_itin_type.have_paperwork")
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('questions.triage_doc_type.edit.title'))
    choose strip_html_tags(I18n.t("questions.triage_doc_type.edit.doc_type.need_help_html"))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('questions.triage_income_types.edit.title'))
    check I18n.t('general.none_of_the_above')
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t("questions.triage_deluxe.edit.title"))
  end

  scenario "clients who don't need assistance are routed to diy" do
    visit "/en/questions/welcome"

    expect(page).to have_selector("h1", text: I18n.t('views.questions.welcome.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('questions.triage_income_level.edit.title').split("\n").first)
    choose I18n.t('questions.triage_income_level.edit.levels.zero')
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('questions.triage_start_ids.edit.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('questions.triage_id_type.edit.title'))
    choose I18n.t("questions.triage_id_type.edit.ssn_itin_type.have_paperwork")
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('questions.triage_doc_type.edit.title'))
    choose strip_html_tags(I18n.t("questions.triage_doc_type.edit.doc_type.all_copies_html"))
    click_on I18n.t('general.continue')

    # To be eligible for free DIY from our perspective, they need to have filed the previous years' returns
    expect(page).to have_selector("h1", text: I18n.t('questions.triage_backtaxes_years.edit.title'))
    check (TaxReturn.current_tax_year - 3).to_s
    check (TaxReturn.current_tax_year - 2).to_s
    check (TaxReturn.current_tax_year - 1).to_s
    click_on I18n.t('general.continue')

    # Since they don't need assistance, they'll be routed to DIY. We can skip the income types page;
    # that page only exists to turn full-service clients into DIY clients, and these are already
    # destined for DIY.
    expect(page).to have_selector("h1", text: I18n.t('questions.triage_assistance.edit.title'))
    check I18n.t("general.none_of_the_above")
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text: I18n.t("questions.triage_referral.edit.title"))
  end
end
