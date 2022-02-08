require "rails_helper"

RSpec.feature "Coalition lead role" do
  context "A logged in coalition lead" do
    let(:coalition) { create :coalition }
    let(:organization) { create :organization, coalition: coalition }
    let(:site) { create :site, parent_organization: organization }
    let(:user) { create :coalition_lead_user, role: create(:coalition_lead_role, coalition: coalition) }

    let!(:clarence_visible) {
      create :client,
             vita_partner: organization,
             intake: create(:intake, :filled_out, :with_contact_info, preferred_name: "Clarence Cabbage", primary_consented_to_service_at: 1.day.ago, state_of_residence: "CA"),
             tax_returns: [(create :tax_return, :intake_in_progress, year: 2019)]
    }
    let!(:greta_visible) {
      create :client,
             vita_partner: site,
             intake: create(:intake, :filled_out, preferred_name: "Greta Gherkin", primary_consented_to_service_at: 1.day.ago),
             tax_returns: [(create :tax_return, :intake_in_progress, year: 2019)]
    }
    let!(:shep_invisible) {
      create :client,
             vita_partner: create(:organization),
             intake: (create :intake, :filled_out, preferred_name: "Shep Shallot", primary_consented_to_service_at: 1.day.ago),
             tax_returns: [(create :tax_return, :intake_in_progress, year: 2018)]
    }

    before do
      login_as user
    end

    scenario "Viewing client list", :js do
      visit hub_clients_path

      expect(page).to have_selector(".selected", text: "All Clients")

      within ".client-table" do
        expect(page).to have_text(greta_visible.preferred_name)
        expect(page).to have_text(clarence_visible.preferred_name)
        expect(page).not_to have_text(shep_invisible.preferred_name)
      end
    end
    
    scenario "Editing client" do
      visit hub_clients_path

      within ".client-table" do
        click_on "Clarence Cabbage"
      end

      within ".client-profile" do
        click_on "Edit"
      end

      within "#primary-info" do
        fill_in "Preferred full name", with: "Clarinet"
        fill_in "Legal first name", with: "Clarense"
        fill_in "Legal last name", with: "Cabbagepatch"

        check "Opt into email notifications"
      end

      click_on "Save"

      expect(page).to have_text "Clarinet"
      expect(page).to have_text "Clarense Cabbagepatch"
    end
  end
end
