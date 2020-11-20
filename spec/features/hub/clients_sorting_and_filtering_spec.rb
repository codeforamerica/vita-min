require "rails_helper"

RSpec.describe "sorting and filtering clients" do
  context "as an admin user" do
    let(:user) { create :admin_user, vita_partner: create(:vita_partner) }

    before { login_as user }

    context "without clients" do
      scenario "I should see the empty message" do
        visit hub_clients_path
        expect(page).to have_text("No clients assigned.")
      end
    end

    context "with clients to sort and filter" do
      let!(:alan_intake_in_progress) { create :client, intake: (create :intake, preferred_name: "Alan Avocado"), tax_returns: [(create :tax_return, status: "intake_in_progress")] }
      let!(:betty_intake_in_progress) { create :client, intake: (create :intake, preferred_name: "Betty Banana"), tax_returns: [(create :tax_return, status: "intake_in_progress")] }
      let!(:patty_prep_ready_for_call) { create :client, intake: (create :intake, preferred_name: "Patty Persimmon"), tax_returns: [(create :tax_return, status: "prep_ready_for_call")] }
      let!(:zach_prep_ready_for_call) { create :client, intake: (create :intake, preferred_name: "Zach Zucchini"), tax_returns: [(create :tax_return, status: "prep_ready_for_call")] }

      scenario "I can view all clients and sort/filter" do
        visit hub_clients_path

        expect(page).to have_text "All clients"
        within ".client-table" do
          expect(page).to have_text(alan_intake_in_progress.preferred_name)
          expect(page).to have_text(betty_intake_in_progress.preferred_name)
          expect(page).to have_text(patty_prep_ready_for_call.preferred_name)
          expect(page).to have_text(zach_prep_ready_for_call.preferred_name)
        end

        within ".client-filters" do
          select "Ready for call", from: "status"
          click_button "Apply"
          expect(page).to have_select("status-filter", selected: "Ready for call")
        end

        within ".client-table" do
          expect(page.all('.client-row').length).to eq 2

          # Sort one direction
          click_link "sort-preferred_name"
          expect(page.all('.client-row').length).to eq 2 # make sure filter is retained
          expect(page.all('.client-row')[0]).to have_text(patty_prep_ready_for_call.preferred_name)
          expect(page.all('.client-row')[1]).to have_text(zach_prep_ready_for_call.preferred_name)

          # Sort opposite direction
          click_link "sort-preferred_name"
          expect(page.all('.client-row').length).to eq 2 # make sure filter is retained
          expect(page.all('.client-row')[1]).to have_text(patty_prep_ready_for_call.preferred_name)
          expect(page.all('.client-row')[0]).to have_text(zach_prep_ready_for_call.preferred_name)
        end
        within ".client-filters" do
          click_button "Clear Filters"
        end
        within ".client-table" do
          expect(page.all('.client-row').length).to eq 4
        end
      end
    end
  end
end
