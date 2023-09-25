require "rails_helper"

RSpec.feature "Visiting the old URL for the welcome page" do
  scenario "redirects to /questions/triage-personal-info" do
    visit "/questions/welcome"

    expect(page).to have_text I18n.t('views.questions.personal_info.title')
  end
end
