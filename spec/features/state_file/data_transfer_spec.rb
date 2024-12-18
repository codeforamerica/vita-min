require "rails_helper"

RSpec.feature "Transferring data from Direct File", active_job: true do
  include MockTwilio
  include StateFileIntakeHelper

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
    Flipper.enable :sms_notifications
  end

  it "advances past the loading screen by listening for an actioncable broadcast", js: true do
    visit "/"
    click_on "Start Test NY"

    expect(page).to have_text "File your New York State taxes for free"
    click_on "Get Started", id: "firstCta"

    step_through_eligibility_screener(us_state: "ny")

    step_through_initial_authentication(contact_preference: :email)
    check "Text message"
    fill_in "Your phone number", with: "+12025551212"
    click_on "Continue"

    expect(page).to have_text I18n.t('state_file.questions.sms_terms.edit.title')
    click_on I18n.t("general.accept")

    expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
    click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

    step_through_df_data_transfer("Transfer Javier")
    expect(page).to have_text "Note: New York City includes the Bronx, Brooklyn, Manhattan, Queens, and Staten Island."
  end
end
