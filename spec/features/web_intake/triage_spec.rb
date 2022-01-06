require "rails_helper"

RSpec.feature "client is not eligible for VITA services", :flow_explorer_screenshot do
  scenario "client is over the income limit" do
    visit "/en/questions/welcome"

    expect(page).to have_selector("h1", text: I18n.t('views.questions.welcome.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('questions.triage_income_level.edit.title').split("\n").first)
    choose I18n.t('questions.triage_income_level.edit.levels.hh_over_73000')
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('views.public_pages.maybe_ineligible.title'))
  end

  scenario "client is eligible for DIY but not full service" do
    visit "/en/questions/welcome"

    expect(page).to have_selector("h1", text: I18n.t('views.questions.welcome.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('questions.triage_income_level.edit.title').split("\n").first)
    choose I18n.t('questions.triage_income_level.edit.levels.hh_66000_to_73000')
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('diy.file_yourself.edit.title'))
  end
end
