require "rails_helper"

RSpec.feature "Menu spec", js: true do
  scenario "menu when mobile" do
    resize_window_to_mobile
    visit "/"
    within ".toolbar" do
      # TODO: address why this fails locally; the resize_window_to_mobile will not size width < 500px
      expect(page).not_to have_selector("a", text: "Login")
    end
    within ".toolbar" do
      expect(page).to have_selector("[data-component='ClientMenuTrigger']", text: "Menu")
      find("[data-component='ClientMenuTrigger']").click
    end
    expect(page).to have_selector("a", text: "Login")
  end

  scenario "menu when desktop" do
    resize_window_to_desktop

    visit "/"
    within ".toolbar" do
      expect(page).to have_selector("a", text: "Login")
    end
  end
end
