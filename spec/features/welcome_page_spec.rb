require "rails_helper"

RSpec.feature "Visit welcome page" do
  scenario "redirects to /questions/triage-personal-info", js: true, screenshot: true do
    visit "/questions/welcome"

    # screenshot_after do
    #   within(".main-header") do
    #     expect(page).to have_link("GetYourRefund", href: root_path)
    #   end
    #   expect(page).to have_text "Free tax filing"
    #   within ".slab--hero" do
    #     expect(page).to have_link I18n.t('general.get_started')
    #   end
    # end
    #
    # within ".slab--hero" do
    #   click_on I18n.t('general.get_started')
    # end
    expect(page).to have_text I18n.t('views.questions.personal_info.title')
  end
end
