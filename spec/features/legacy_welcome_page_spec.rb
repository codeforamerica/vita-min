require "rails_helper"

RSpec.feature "Visiting the old URL for the welcome page" do
  scenario "redirects to /questions/eligibility_wages" do
    visit "/questions/welcome"

    expect(page).to have_text I18n.t('questions.eligibility_wages.edit.title')
  end
end
