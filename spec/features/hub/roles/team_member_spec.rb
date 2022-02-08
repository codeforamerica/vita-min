require "rails_helper"

RSpec.feature "Team member role" do
  context "A logged in team member" do
    let!(:vita_partner) { create :site, name: "Squash Site" }
    let(:user) { create :team_member_user, role: create(:team_member_role, site: vita_partner) }
    # TODO: create a factory for users that will show up on the client list (consented, etc)
    # TODO: also, there should be an easier way to create a client that will not fail the edit form validations (currently this looks like create(:intake, :with_contact_info, :filled_out, state_of_residence: "CA"))
    let!(:hester_intake) { create(:intake, :filled_out, :with_contact_info, preferred_name: "Hester Horseradish", primary_consented_to_service_at: 1.day.ago, state_of_residence: "CA") }
    let!(:hester_visible) {
      create :client,
             vita_partner: vita_partner,
             intake: hester_intake,
             tax_returns: [(create :tax_return, :intake_in_progress, year: 2019)]
    }
    let!(:jerry_visible) {
      create :client,
             vita_partner: vita_partner,
             intake: (create :intake, :filled_out, preferred_name: "Jerry Jujube", primary_consented_to_service_at: 1.day.ago, state_of_residence: "CA"),
             tax_returns: [(create :tax_return, :intake_in_progress, year: 2021)]
    }
    let!(:abigail_invisible) {
      create :client,
             vita_partner: create(:organization),
             intake: (create :intake, preferred_name: "Abigail Apricot", primary_consented_to_service_at: 1.day.ago, state_of_residence: "CA"),
             tax_returns: [(create :tax_return, :intake_in_progress, year: 2018)]
    }
    let!(:mirabel_invisible) {
      create :client,
             vita_partner: create(:organization),
             intake: (create :intake, preferred_name: "Mirabel Mushroom", primary_consented_to_service_at: 1.day.ago, state_of_residence: "CA"),
             tax_returns: [(create :tax_return, :intake_in_progress, year: 2019)]
    }

    before do
      login_as user
    end

    scenario "Viewing client list", :js do
      visit hub_clients_path

      expect(page).to have_selector(".selected", text: "All Clients")

      within ".client-table" do
        expect(page).to have_text(hester_visible.preferred_name)
        expect(page).to have_text(jerry_visible.preferred_name)
        expect(page).not_to have_text(abigail_invisible.preferred_name)
        expect(page).not_to have_text(mirabel_invisible.preferred_name)
      end
    end
    
    scenario "Editing client" do
      visit hub_clients_path

      within ".client-table" do
        click_on "Hester Horseradish"
      end

      within ".client-profile" do
        click_on "Edit"
      end

      within "#primary-info" do
        fill_in "Preferred full name", with: "Hesty"
        fill_in "Email", with: "hesty@horseradish.com"

        # the below line should pass because `email_notification_opt_in: "yes"` is included in the :with_contact_info trait on the intake factory
        # instead, it intermittently fails and the print statement `puts hester_intake.email_notification_opt_in` returns "yes" "no" and "unfilled" seemingly at random
        #   expect(page).to have_field("Opt into email notifications", checked: true)
        # ^ this expectation did not originally exist but better illustrates the problem than line 76 (which was originally failing)
        # note that the other specs in this directory (roles) will have to be fixed as well
        check "Opt into email notifications"
      end

      click_on "Save"

      expect(page).to have_text "Hesty"
      expect(page).to have_text "hesty@horseradish.com"
    end
  end
end
