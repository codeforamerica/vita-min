require "rails_helper"

RSpec.feature "Team member role" do
  context "A logged in team member" do
    let!(:vita_partner) { create :site, name: "Squash Site" }
    let(:user) { create :team_member_user, role: create(:team_member_role, site: vita_partner) }
    # TODO: create a factory for users that will show up on the client list (consented, etc)
    let!(:hester_visible) {
      create :client,
             vita_partner: vita_partner,
             intake: (create :intake, preferred_name: "Hester Horseradish", primary_consented_to_service_at: 1.day.ago, state_of_residence: "CA"),
             tax_returns: [(create :tax_return, year: 2019, status: "intake_in_progress")]
    }
    let!(:jerry_visible) {
      create :client,
             vita_partner: vita_partner,
             intake: (create :intake, preferred_name: "Jerry Jujube", primary_consented_to_service_at: 1.day.ago, state_of_residence: "CA"),
             tax_returns: [(create :tax_return, year: 2020, status: "intake_in_progress")]
    }
    let!(:abigail_invisible) {
      create :client,
             vita_partner: create(:vita_partner),
             intake: (create :intake, preferred_name: "Abigail Apricot", primary_consented_to_service_at: 1.day.ago, state_of_residence: "CA"),
             tax_returns: [(create :tax_return, year: 2018, status: "intake_in_progress")]
    }
    let!(:mirabel_invisible) {
      create :client,
             vita_partner: create(:vita_partner),
             intake: (create :intake, preferred_name: "Mirabel Mushroom", primary_consented_to_service_at: 1.day.ago, state_of_residence: "CA"),
             tax_returns: [(create :tax_return, year: 2019, status: "intake_in_progress")]
    }

    before do
      login_as user
    end

    scenario "Viewing client list" do
      visit hub_clients_path

      expect(page).to have_text "All clients"
      within ".client-table" do
        expect(page).to have_text(hester_visible.preferred_name)
        expect(page).to have_text(jerry_visible.preferred_name)
        expect(page).not_to have_text(abigail_invisible.preferred_name)
        expect(page).not_to have_text(mirabel_invisible.preferred_name)
      end
    end
  end
end
