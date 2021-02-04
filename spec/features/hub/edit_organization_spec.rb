require "rails_helper"

RSpec.describe "a user editing an organization" do
  context "as an authenticated user" do
    context "as an admin" do
      let(:current_user) { create :admin_user }
      let(:organization) { create :organization }
      let!(:site) { create :site, parent_organization: organization, name: "Child Site" }
      before { login_as current_user }

      scenario "navigation" do
        visit edit_hub_organization_path(id: organization.id)
        click_on "All organizations"
        expect(page).to have_current_path(hub_organizations_path)

      end

      scenario "updating timezone" do
        visit edit_hub_organization_path(id: organization.id)
        expect(page).to have_select("Timezone", selected: "Eastern Time (US & Canada)")

        select "Central Time (US & Canada)", from: "Timezone"

        click_on "Save"

        expect(page).to have_text "Changes saved"

        expect(page).to have_select("Timezone", selected: "Central Time (US & Canada)")

        # Now do the same for the child site

        click_on "Child Site"

        expect(find_field('Name').value).to eq 'Child Site'

        expect(page).to have_select("Timezone", selected: "Eastern Time (US & Canada)")

        select "Central Time (US & Canada)", from: "Timezone"

        click_on "Save"

        expect(page).to have_text "Changes saved"

        expect(page).to have_select("Timezone", selected: "Central Time (US & Canada)")

      end
    end
  end
end
