require "rails_helper"

RSpec.describe "searching, sorting, and filtering clients" do
  context "as an admin user" do
    let(:user) { create :admin_user, vita_partner: create(:vita_partner) }

    before { login_as user }

    context "without clients" do
      scenario "I should see the empty message" do
        visit hub_clients_path
        expect(page).to have_text("No clients assigned.")
      end
    end

    context "with existing clients" do
      let!(:alan_intake_in_progress) { create :client, intake: (create :intake, preferred_name: "Alan Avocado"), tax_returns: [(create :tax_return, year: 2019, status: "intake_in_progress", assigned_user: user)] }
      let!(:betty_intake_in_progress) { create :client, intake: (create :intake, preferred_name: "Betty Banana"), tax_returns: [(create :tax_return, year: 2018, status: "intake_in_progress")] }
      let!(:patty_prep_ready_for_call) { create :client, intake: (create :intake, preferred_name: "Patty Banana"), tax_returns: [(create :tax_return, year: 2019, status: "prep_ready_for_call", assigned_user: user)] }
      let!(:zach_prep_ready_for_call) { create :client, intake: (create :intake, preferred_name: "Zach Zucchini"), tax_returns: [(create :tax_return, year: 2018, status: "prep_ready_for_call")] }

      scenario "I can view all clients and search, sort, and filter" do
        visit hub_clients_path

        expect(page).to have_text "All clients"
        within ".client-table" do
          expect(page).to have_text(alan_intake_in_progress.preferred_name)
          expect(page).to have_text(betty_intake_in_progress.preferred_name)
          expect(page).to have_text(patty_prep_ready_for_call.preferred_name)
          expect(page).to have_text(zach_prep_ready_for_call.preferred_name)
        end

        # search for client
        fill_in "Search", with: "Zach"
        click_button "Apply"
        expect(page.all('.client-row').length).to eq 1
        expect(page.all('.client-row')[0]).to have_text(zach_prep_ready_for_call.preferred_name)
        click_button "Clear filters"

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
          click_button "Clear filters"
        end
        within ".client-table" do
          expect(page.all('.client-row').length).to eq 4
        end

        within ".client-filters" do
          select "2019", from: "year"
          click_button "Apply"
          expect(page).to have_select("year", selected: "2019")
        end
        within ".client-table" do
          expect(page.all('.client-row').length).to eq 2
        end

        # search for client within 2019 filtered results
        fill_in "Search", with: "Banana"
        click_button "Apply"
        expect(page.all('.client-row').length).to eq 1
        expect(page.all('.client-row')[0]).to have_text(patty_prep_ready_for_call.preferred_name)

        within ".client-filters" do
          click_button "Clear filters"
        end
        within ".client-table" do
          expect(page.all('.client-row').length).to eq 4
        end
        within ".client-filters" do
          select "2019", from: "year"
          select "Ready for call", from: "status"
          click_button "Apply"
          expect(page).to have_select("status-filter", selected: "Ready for call")
          expect(page).to have_select("year", selected: "2019")
        end
        within ".client-table" do
          expect(page.all('.client-row').length).to eq 1
        end
        within ".client-filters" do
          click_button "Clear filters"
        end
        within ".client-table" do
          expect(page.all('.client-row').length).to eq 4
        end
        within ".client-filters" do
          check "assigned_to_me"
          select "Ready for call", from: "status"
          select "2019", from: "year"
          click_button "Apply"
          expect(page).to have_select("status-filter", selected: "Ready for call")
          expect(page).to have_select("year", selected: "2019")
          expect(page).to have_checked_field("assigned_to_me")
        end
        within ".client-table" do
          expect(page.all('.client-row').length).to eq 1
        end
        within ".client-filters" do
          select "2018", from: "year"
          click_button "Apply"
          expect(page).to have_select("status-filter", selected: "Ready for call")
          expect(page).to have_checked_field("assigned_to_me")
          expect(page).to have_select("year", selected: "2018")
        end
        expect(page).not_to have_css ".client-table"
        expect(page).to have_css ".empty-clients"
      end
    end
  end
end
