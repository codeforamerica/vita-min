require "rails_helper"

RSpec.feature "editing direct file XML with the FederalInfoController", active_job: true do
  include MockTwilio
  include StateFileIntakeHelper

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
  end

  it "does not modify the df xml if nothing was changed" do
    visit "/"
    click_on "Start Test NY"

    expect(page).to have_text "File your New York state taxes for free"
    click_on "Get Started", id: "firstCta"

    step_through_eligibility_screener(us_state: "ny")

    step_through_initial_authentication(contact_preference: :text_message)

    step_through_df_data_transfer

    xml_before = StateFileNyIntake.last.raw_direct_file_data.strip

    click_on "visit_federal_info_controller"
    expect(page).to have_select("state_file_federal_info_form[filing_status]", selected: "head of household")

    click_on I18n.t("general.continue")

    expect(page).to have_text I18n.t('state_file.questions.name_dob.edit.title')

    xml_after = StateFileNyIntake.last.raw_direct_file_data.strip
    expect(xml_before).to eq(xml_after)
  end
end
