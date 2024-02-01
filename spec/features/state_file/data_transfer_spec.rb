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

    step_through_initial_authentication(contact_preference: :text_message)

    expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
    click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

    step_through_df_data_transfer
    click_on "visit_federal_info_controller"
    expect(page).to have_select("state_file_federal_info_form[filing_status]", selected: "head of household")
  end
end
