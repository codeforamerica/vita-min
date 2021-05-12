require "rails_helper"

RSpec.feature "Web Intake Client matches with partner who is at capacity" do
  let(:intake) { create :intake }
  before do
    allow_any_instance_of(ApplicationController).to receive(:current_intake).and_return(intake)
  end

  scenario "client decides cannot continue with help at capacity" do
    visit at_capacity_questions_path

    expect(page).to have_selector("h1", text: "Wow, it looks like we are at capacity right now.")
    # temporarily remove file with help button
    expect(page).not_to have_selector("button", text: "File with help")

    # click_on "File with help"
    # expect(page).to have_selector("h1", text: "Our team at is here to help!")
    expect(intake.viewed_at_capacity).to be_truthy
    # expect(intake.continued_at_capacity).to be_truthy
  end

  scenario "client chooses the DIY option" do
    visit at_capacity_questions_path

    expect(page).to have_text "To file by the tax deadline, you can try our free 'Do it Yourself' option."
    expect(page).to have_selector("h1", text: "Wow, it looks like we are at capacity right now.")
    click_on "Continue to TaxSlayer"

    expect(page).to have_selector("h1", text: "To access this site, please provide your e-mail address.")
    expect(intake.viewed_at_capacity).to be_truthy
    expect(intake.continued_at_capacity).to be_falsey
  end
end

