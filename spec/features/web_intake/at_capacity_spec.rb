require "rails_helper"

RSpec.feature "Web Intake Client matches with partner who is at capacity", :flow_explorer_screenshot do
  let(:intake) { create :intake }
  before do
    allow_any_instance_of(ApplicationController).to receive(:current_intake).and_return(intake)
  end

  scenario "client decides cannot continue to diy" do
    visit at_capacity_questions_path

    expect(page).to have_selector("h1", text: I18n.t("views.questions.at_capacity.title"))
    # temporarily remove file with help button
    click_on I18n.t("views.questions.at_capacity.return_to_homepage")
    expect(page).to have_selector("h1", text:  I18n.t("views.public_pages.home.header"))

  end

  scenario "client chooses the DIY option" do
    visit at_capacity_questions_path

    expect(page).to have_text I18n.t("views.questions.at_capacity.body_html")[1]
    expect(page).to have_selector("h1", text: I18n.t("views.questions.at_capacity.title"))
    click_on I18n.t("views.questions.at_capacity.continue_to_diy")

    expect(page).to have_selector("h1", text: "To access this site, please provide your e-mail address.")
    expect(intake.viewed_at_capacity).to be_truthy
    expect(intake.continued_at_capacity).to be_falsey
  end
end

