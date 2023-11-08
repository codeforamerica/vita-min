require "rails_helper"

RSpec.feature "Transferring data from Direct File", active_job: true do
  include MockTwilio
  include StateFileIntakeHelper

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
  end

  it "advances past the loading screen by listening for an actioncable broadcast", js: true do
    visit "/"
    click_on "Start Test NY"

    expect(page).to have_text "File your New York state taxes for free"
    click_on "Get Started", id: "firstCta"

    step_through_initial_authentication(contact_preference: :text_message)

    step_through_df_data_transfer
    click_on "Continue"

    expect(page).to have_text "The page with all the info from the 1040"
  end
end
