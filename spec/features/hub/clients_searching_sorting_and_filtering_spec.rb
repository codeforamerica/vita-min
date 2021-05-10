require "rails_helper"

RSpec.describe "searching, sorting, and filtering clients" do
  context "as an admin user" do
    let(:user) { create :admin_user }
    let(:mona_user) { create :user, name: "Mona Mandarin" }

    before { login_as user }

    context "without clients" do
      scenario "I should see the empty message" do
        visit hub_clients_path
        expect(page).to have_text("No clients assigned.")
      end
    end

    context "with existing clients" do
      let(:vita_partner) { create :vita_partner, name: "Alan's Org" }
      let!(:vita_partner_other) { create :vita_partner, name: "Some Other Org", allows_greeters: true }
      let!(:alan_intake_in_progress) { create :client, vita_partner_id: vita_partner.id, intake: (create :intake, preferred_name: "Alan Avocado", created_at: 1.day.ago, state_of_residence: "CA"), last_outgoing_communication_at: Time.new(2021, 4, 23), tax_returns: [(create :tax_return, year: 2019, status: "intake_in_progress", assigned_user: user)] }
      let!(:betty_intake_in_progress) { create :client, vita_partner_id: vita_partner_other.id, intake: (create :intake, preferred_name: "Betty Banana", created_at: 2.days.ago, state_of_residence: "TX"), last_outgoing_communication_at: Time.new(2021, 4, 28), tax_returns: [(create :tax_return, year: 2018, status: "intake_in_progress", assigned_user: mona_user)] }
      let!(:patty_prep_ready_for_call) { create :client, vita_partner_id: vita_partner_other.id, intake: (create :intake, preferred_name: "Patty Banana", created_at: 1.day.ago, state_of_residence: "AL"), last_outgoing_communication_at: Time.new(2021, 5, 1), tax_returns: [(create :tax_return, year: 2019, status: "prep_ready_for_prep", assigned_user: user)] }
      let!(:zach_prep_ready_for_call) { create :client, vita_partner_id: vita_partner_other.id, intake: (create :intake, preferred_name: "Zach Zucchini", created_at: 3.days.ago, state_of_residence: "WI"), last_outgoing_communication_at: Time.new(2021, 5, 3), tax_returns: [(create :tax_return, year: 2018, status: "prep_ready_for_prep")] }

      before do
        allow(DateTime).to receive(:now).and_return DateTime.new(2021, 5, 4)
      end

      scenario "I can view all clients and search, sort, and filter" do
        visit hub_clients_path

        expect(page).to have_text "All clients"
        within ".client-table" do
          # Default sort order
          expect(page.all('.client-row')[0]).to have_text(alan_intake_in_progress.preferred_name)
          expect(page.all('.client-row')[1]).to have_text(betty_intake_in_progress.preferred_name)
          expect(page.all('.client-row')[2]).to have_text(patty_prep_ready_for_call.preferred_name)
          expect(page.all('.client-row')[3]).to have_text(zach_prep_ready_for_call.preferred_name)
        end

        # search for client
        fill_in "Search", with: "Zach"
        click_button "Filter results"
        expect(page.all('.client-row').length).to eq 1
        expect(page.all('.client-row')[0]).to have_text(zach_prep_ready_for_call.preferred_name)
        click_link "Clear"

        within ".filter-form" do
          select "Alan's Org", from: "vita_partner_id"
          click_button "Filter results"
          expect(page).to have_select("vita_partner_id", selected: "Alan's Org")
        end

        expect(page.all('.client-row').length).to eq 1
        expect(page.all('.client-row')[0]).to have_text alan_intake_in_progress.preferred_name
        click_link "Clear"

        within ".filter-form" do
          select "Alan's Org", from: "vita_partner_id"
          select "2020", from: "year"
          select "Mona Mandarin", from: "assigned_user_id"
          select "Ready for prep", from: "status"
          fill_in "Search", with: "Zach"

          click_button "Filter results"
          expect(page).to have_select("vita_partner_id", selected: "Alan's Org")
          expect(page).to have_select("year", selected: "2020")
          expect(page).to have_select("assigned_user_id", selected: "Mona Mandarin")
          expect(page).to have_select("status", selected: "Ready for prep")

          # reload page and filters persist
          visit hub_clients_path
          expect(page).to have_select("vita_partner_id", selected: "Alan's Org")
          expect(page).to have_select("year", selected: "2020")
          expect(page).to have_select("assigned_user_id", selected: "Mona Mandarin")
          expect(page).to have_select("status", selected: "Ready for prep")

          visit hub_root_path
          expect(page).to have_select("vita_partner_id", selected: nil)
          expect(page).to have_select("year", selected: nil)
          expect(page).to have_select("status", selected: nil)

          select "Some Other Org", from: "vita_partner_id"
          select "2019", from: "year"
          select "Not filing", from: "status"
          fill_in "Search", with: "Bob"
          click_button "Filter results"
          # Filters persist after submitting with filters
          expect(page).to have_select("vita_partner_id", selected: "Some Other Org")
          expect(page).to have_select("year", selected: "2019")
          expect(page).to have_select("status", selected: "Not filing")

          # Filters persist when visiting the page directly
          visit hub_root_path
          expect(page).to have_select("vita_partner_id", selected: "Some Other Org")
          expect(page).to have_select("year", selected: "2019")
          expect(page).to have_select("status", selected: "Not filing")

          # Can navigate to another dashboard and see that pages persisted filters again.
          visit hub_clients_path
          expect(page).to have_select("vita_partner_id", selected: "Alan's Org")
          expect(page).to have_select("year", selected: "2020")
          expect(page).to have_select("assigned_user_id", selected: "Mona Mandarin")
          expect(page).to have_select("status", selected: "Ready for prep")
        end
        # Clear links on hub_clients_path filter form
        click_link "Clear"

        within ".filter-form" do
          select "Mona Mandarin", from: "assigned_user_id"
          click_button "Filter results"
          expect(page).to have_select("assigned_user_id", selected: "Mona Mandarin")
        end

        expect(page.all('.client-row').length).to eq 1
        expect(page.all('.client-row')[0]).to have_text betty_intake_in_progress.preferred_name
        click_link "Clear"

        within ".filter-form" do
          select "Ready for prep", from: "status"
          click_button "Filter results"
          expect(page).to have_select("status-filter", selected: "Ready for prep")
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

          #zach, betty, patty (oldest to youngest created at)
          click_link "sort-created_at"
          expect(page.all('.client-row').length).to eq 2 # make sure filter is retained
          expect(page.all('.client-row')[0]).to have_text(zach_prep_ready_for_call.preferred_name)
          expect(page.all('.client-row')[1]).to have_text(patty_prep_ready_for_call.preferred_name)

          click_link "sort-created_at"
          expect(page.all('.client-row').length).to eq 2 # make sure filter is retained
          expect(page.all('.client-row')[0]).to have_text(patty_prep_ready_for_call.preferred_name)
          expect(page.all('.client-row')[1]).to have_text(zach_prep_ready_for_call.preferred_name)
        end
        within ".filter-form" do
          click_link "Clear"
        end
        within ".client-table" do
          expect(page.all('.client-row').length).to eq 4
        end

        # sort by state of residence ASC
        click_link "sort-state_of_residence"
        expect(page.all('.client-row').length).to eq 4 # make sure filter is retained
        expect(page.all('.client-row')[0]).to have_text(patty_prep_ready_for_call.preferred_name) # AL
        expect(page.all('.client-row')[1]).to have_text(alan_intake_in_progress.preferred_name) # CA
        expect(page.all('.client-row')[2]).to have_text(betty_intake_in_progress.preferred_name) # TX
        expect(page.all('.client-row')[3]).to have_text(zach_prep_ready_for_call.preferred_name) # WI

        # sort by state of residence DESC
        click_link "sort-state_of_residence"
        expect(page.all('.client-row').length).to eq 4 # make sure filter is retained
        expect(page.all('.client-row')[0]).to have_text(zach_prep_ready_for_call.preferred_name)

        # return to default sort order
        click_link "sort-last_outgoing_communication_at"
        expect(page.all('.client-row')[0]).to have_text(alan_intake_in_progress.preferred_name)
        expect(page.all('.client-row')[0]).to have_text("7 business days")
        expect(page.all('.client-row')[0]).to have_css(".text--red-bold")
        expect(page.all('.client-row')[1]).to have_text(betty_intake_in_progress.preferred_name)
        expect(page.all('.client-row')[1]).to have_text("4 business days")
        expect(page.all('.client-row')[1]).not_to have_css(".text--red-bold")
        expect(page.all('.client-row')[2]).to have_text(patty_prep_ready_for_call.preferred_name)
        expect(page.all('.client-row')[2]).to have_text("1 business day")
        expect(page.all('.client-row')[3]).to have_text(zach_prep_ready_for_call.preferred_name)
        expect(page.all('.client-row')[3]).to have_text("1 business day")

        within ".filter-form" do
          select "2019", from: "year"
          click_button "Filter results"
          expect(page).to have_select("year", selected: "2019")
        end
        within ".client-table" do
          expect(page.all('.client-row').length).to eq 2
        end

        # search for client within 2019 filtered results
        fill_in "Search", with: "Banana"
        click_button "Filter results"
        expect(page.all('.client-row').length).to eq 1
        expect(page.all('.client-row')[0]).to have_text(patty_prep_ready_for_call.preferred_name)

        within ".filter-form" do
          click_link "Clear"
        end
        within ".client-table" do
          expect(page.all('.client-row').length).to eq 4
        end
        within ".filter-form" do
          select "2019", from: "year"
          select "Ready for prep", from: "status"
          click_button "Filter results"
          expect(page).to have_select("status-filter", selected: "Ready for prep")
          expect(page).to have_select("year", selected: "2019")
        end
        within ".client-table" do
          expect(page.all('.client-row').length).to eq 1
        end
        within ".filter-form" do
          click_link "Clear"
        end
        within ".client-table" do
          expect(page.all('.client-row').length).to eq 4
        end
        within ".filter-form" do
          check "assigned_to_me"
          select "Ready for prep", from: "status"
          select "2019", from: "year"
          click_button "Filter results"
          expect(page).to have_select("status-filter", selected: "Ready for prep")
          expect(page).to have_select("year", selected: "2019")
          expect(page).to have_checked_field("assigned_to_me")
        end
        within ".client-table" do
          expect(page.all('.client-row').length).to eq 1
        end
        within ".filter-form" do
          select "2018", from: "year"
          click_button "Filter results"
          expect(page).to have_select("status-filter", selected: "Ready for prep")
          expect(page).to have_checked_field("assigned_to_me")
          expect(page).to have_select("year", selected: "2018")
        end
        expect(page).not_to have_css ".client-table"
        expect(page).to have_css ".empty-clients"

        # filter for greetable clients
        within ".filter-form" do
          click_link "Clear"
          check "greetable"
          click_button "Filter results"
        end
        within ".client-table" do
          expect(page).not_to have_text(alan_intake_in_progress.preferred_name)
          expect(page).to have_text(betty_intake_in_progress.preferred_name)
          expect(page).to have_text(patty_prep_ready_for_call.preferred_name)
          expect(page).to have_text(zach_prep_ready_for_call.preferred_name)
        end
      end
    end
  end
end
