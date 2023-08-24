require "rails_helper"

RSpec.feature "Switching Locale" do

  scenario "client switches between Spanish and English versions of website using the header link" do
    visit root_path

    within(".main-header") do
      click_on "Español"
    end
    expect(page).to have_content(I18n.t("views.public_pages.home.header", locale: :es))

    within(".main-header") do
      click_on "English"
    end
    expect(page).to have_content(I18n.t("views.public_pages.home.header", locale: :en))
  end
end
