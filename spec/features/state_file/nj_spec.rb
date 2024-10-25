require "rails_helper"
require 'axe-capybara'
require 'axe-rspec'

RSpec.feature "NJ minimal", active_job: true do
  include MockTwilio
  include StateFileIntakeHelper

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
    Flipper.enable :sms_notifications
  end

  it "advances past the loading screen by listening for an actioncable broadcast", js: true do
    visit "/"
    click_on "Start Test NJ"

    expect(page).to have_text "File your New Jersey taxes for free"
    click_on "Get Started", id: "firstCta"

    # step_through_eligibility_screener(us_state: "nj") - to do after eligibility
    click_on I18n.t("general.continue")

    step_through_initial_authentication(contact_preference: :email)

    expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
    click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

    step_through_df_data_transfer("Transfer Minimal")

    expect(page).to have_text "Your federal tax return is now transferred."
    click_on I18n.t("general.continue")

    # County
    select "Atlantic"
    click_on I18n.t("general.continue")

    # Municipality
    select "Atlantic City"
    click_on I18n.t("general.continue")

    # Medical expenses
    fill_in I18n.t('state_file.questions.nj_medical_expenses.edit.label', filing_year: MultiTenantService.statefile.current_tax_year), with: 1000
    click_on I18n.t("general.continue")

    # Homeowner tenant
    choose "Neither"
    click_on I18n.t("general.continue")
    click_on I18n.t("general.continue")

    # Disabled
    choose "No"
    click_on I18n.t("general.continue")

    # Review
    expect(page).to be_axe_clean.within "main"
    click_on I18n.t("general.continue")

    # Esign
    # Confirmation
  end
end
