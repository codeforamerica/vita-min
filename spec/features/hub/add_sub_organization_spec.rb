require "rails_helper"

RSpec.describe "Create a sub-organization" do
  context "as an admin user" do
    let(:vita_partner) { create :vita_partner, name: "Example Partner", display_name: "Example Partner" }
    let(:current_user) { create :admin_user, vita_partner: vita_partner }
    before { login_as current_user }

    scenario "create a sub-org of your own org" do
      visit hub_user_profile_path
      click_on "VITA partners"

      click_on "Example Partner"
      click_on "Add site"

      fill_in "Name", with: "Example sub-org"
      click_on "Save"

      expect(page).to have_text "Example sub-org"
    end
  end
end
