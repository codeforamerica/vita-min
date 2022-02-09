require "rails_helper"

RSpec.feature "A client who wants help getting an ITIN" do
  scenario "the client fills out triage and makes it past the personal info page" do
    answer_gyr_triage_questions({
      filing_status: "single",
      income_level: "1_to_12500",
      id_type: "need_help",
      doc_type: "need_help",
      filed_past_years: [],
      income_type_options: ['none_of_the_above']
    })

    expect(page).to have_selector("h1", text: I18n.t('questions.triage_gyr.edit.title'))
    click_on I18n.t('questions.triage_gyr.edit.file_online')

    expect(page).to have_selector("h1", text: I18n.t("views.questions.backtaxes.title"))
    check "#{TaxReturn.current_tax_year}"
    click_on "Continue"

    expect(page).to have_text I18n.t('views.questions.environment_warning.title')
    click_on I18n.t('general.continue_example')

    expect(page).to have_selector("h1", text: "Let's get started")
    expect(page).to have_text("We’ll start by asking about your situation in #{TaxReturn.current_tax_year}.")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Just a few simple steps to file!")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "First, let's get some basic information.")
    fill_in "What is your preferred first name?", with: "Gary"
    fill_in "Phone number", with: "8286345533"
    fill_in "Confirm phone number", with: "828-634-5533"
    fill_in "ZIP code", with: "20121"

    # don't show SSN/ITIN fields
    expect(page).not_to have_select(I18n.t("general.tin_type"))
    expect(page).not_to have_field(I18n.t("attributes.primary_ssn"))
    expect(page).not_to have_field(I18n.t("attributes.confirm_primary_ssn"))

    click_on "Continue"

    # next page is interview time preferences
    expect(page).to have_selector("h1", text: I18n.t("views.questions.interview_scheduling.title"))
  end
end
