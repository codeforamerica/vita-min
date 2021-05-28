require "rails_helper"

RSpec.describe "a user editing an organization", :js do
  context "as an authenticated user" do
    context "as an admin" do
      let(:current_user) { create :admin_user }
      let(:organization) { create :organization, capacity_limit: 100, allows_greeters: false }
      let!(:org_lead) { create :organization_lead_user, organization: organization }
      let!(:site) { create :site, parent_organization: organization, name: "Child Site" }
      let!(:site_coordinator) { create :site_coordinator_user, site: site, suspended_at: DateTime.now }
      let!(:team_member) { create :team_member_user, site: site, suspended_at: DateTime.now }
      let!(:team_member2) { create :team_member_user, site: site }

      before { login_as current_user }

      scenario "navigation" do
        visit edit_hub_organization_path(id: organization.id)
        click_on "All organizations"
        expect(page).to have_current_path(hub_organizations_path)

      end

      scenario "updating an organization" do
        visit edit_hub_organization_path(id: organization.id)
        expect(page).to have_select("Timezone", selected: "Eastern Time (US & Canada)")
        expect(find_field('Capacity limit').value).to eq "100"

        select "Central Time (US & Canada)", from: "Timezone"
        fill_in "Capacity limit", with: "200"
        check "Allows Greeters"
        within "#organization-form" do
          click_on "Save"
        end

        expect(page).to have_text "Changes saved"

        expect(page).to have_select("Timezone", selected: "Central Time (US & Canada)")
        expect(find_field('Capacity limit').value).to eq "200"
        expect(find_field('Allows Greeters').value).to eq "true"

        within "#zip-code-routing-form" do
          expect(page).to have_field("Zip code")
          fill_in "Zip code", with: "94606"
          click_on "Save"
          # Now do the same for the child site
        end

        expect(page).to have_text "Admin Controls"
        expect(page).to have_text "Suspend Roles"
        expect(page).to have_text "Organization lead (1/1 active)"
        expect(page).to have_text "Site coordinator (0/1 active)"
        expect(page).to have_text "Team member (1/2 active)"

        within ".role-toggles--organization-lead" do
          expect(page).to have_button('Suspend All', disabled: false)
          expect(page).to have_button('Activate All', disabled: true)
          click_on "Suspend All"
          expect(page).to have_button('Suspend All', disabled: true)
          expect(page).to have_button('Activate All', disabled: false)
        end

        within ".role-toggles--site-coordinator" do
          expect(page).to have_button('Suspend All', disabled: true)
          expect(page).to have_button('Activate All', disabled: false)
          click_on "Activate All"
          expect(page).to have_button('Suspend All', disabled: false)
          expect(page).to have_button('Activate All', disabled: true)
        end

        within ".role-toggles--team-member" do
          expect(page).to have_button('Suspend All', disabled: false)
          expect(page).to have_button('Activate All', disabled: false)
          click_on "Activate All"
          expect(page).to have_button('Suspend All', disabled: false)
          expect(page).to have_button('Activate All', disabled: true)
        end

        click_on "Child Site"

        within "#site-form" do
          expect(find_field('Name').value).to eq 'Child Site'
          expect(page).to_not have_text("Capacity limit")
          expect(page).to have_select("Timezone", selected: "Eastern Time (US & Canada)")

          select "Central Time (US & Canada)", from: "Timezone"

          click_on "Save"

          expect(page).to have_select("Timezone", selected: "Central Time (US & Canada)")

        end


      end
    end
  end
end
