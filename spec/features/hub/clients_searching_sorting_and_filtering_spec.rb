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
      let(:vita_partner) { create :organization, name: "Alan's Org" }
      let(:site) { create :site, name: "Some child site", parent_organization_id: vita_partner_other.id }
      let!(:vita_partner_other) { create :organization, name: "Some Other Org", allows_greeters: true }
      let!(:vita_partner_ctc) { create :organization, name: "CTC Org", processes_ctc: true }
      let!(:alan_intake_in_progress) { create :client, vita_partner_id: vita_partner.id, intake: (create :intake, preferred_name: "Alan Avocado", created_at: 1.day.ago, state_of_residence: "CA"), last_outgoing_communication_at: Time.new(2021, 4, 23), first_unanswered_incoming_interaction_at: Time.new(2021, 4, 23), tax_returns: [(create :tax_return, :intake_in_progress, year: 2019, assigned_user: user)] }
      let!(:zach_prep_ready_for_call) { create :client, vita_partner: vita_partner_other, intake: (create :intake, preferred_name: "Zach Zucchini", created_at: 3.days.ago, state_of_residence: "WI"), last_outgoing_communication_at: Time.new(2021, 4, 28), first_unanswered_incoming_interaction_at: nil, tax_returns: [(create :tax_return, :prep_ready_for_prep, year: 2018)] }
      let!(:patty_prep_ready_for_call) { create :client, vita_partner: vita_partner_other, intake: (create :intake, preferred_name: "Patty Banana", created_at: 1.day.ago, state_of_residence: "AL", with_incarcerated_navigator: true), last_outgoing_communication_at: Time.new(2021, 5, 1), first_unanswered_incoming_interaction_at: Time.new(2021, 5, 1), tax_returns: [(create :tax_return, :prep_ready_for_prep, year: 2019, assigned_user: user)] }
      let!(:marty_ctc) { create :client, vita_partner: vita_partner_ctc, intake: (create :ctc_intake, preferred_name: "Marty Mango", created_at: 5.days.ago, state_of_residence: "ME"), last_outgoing_communication_at: Time.new(2021, 5, 2), first_unanswered_incoming_interaction_at: Time.new(2021, 5, 5), tax_returns: [(create :tax_return, :prep_ready_for_prep, year: 2021)] }
      let!(:betty_intake_in_progress) { create :client, vita_partner: site, intake: (create :intake, preferred_name: "Betty Banana", created_at: 2.days.ago, state_of_residence: "TX", with_general_navigator: true), last_outgoing_communication_at: Time.new(2021, 5, 3), first_unanswered_incoming_interaction_at: Time.new(2021, 4, 28), tax_returns: [(create :tax_return, :intake_in_progress, year: 2018, assigned_user: mona_user)] }

      before do
        allow(DateTime).to receive(:now).and_return DateTime.new(2021, 5, 4)
        Intake.refresh_search_index
      end

      scenario "I can view all clients and search, sort, and filter", js: true do
        visit hub_clients_path

        expect(page).to have_text "All Clients"
        within ".client-table" do
          # Default sort order
          expect(page.all('.client-row')[0]).to have_text(alan_intake_in_progress.preferred_name)
          expect(page.all('.client-row')[1]).to have_text(zach_prep_ready_for_call.preferred_name)
          expect(page.all('.client-row')[2]).to have_text(patty_prep_ready_for_call.preferred_name)
          expect(page.all('.client-row')[3]).to have_text(marty_ctc.preferred_name)
          expect(page.all('.client-row')[4]).to have_text(betty_intake_in_progress.preferred_name)
        end

        # search for client
        fill_in "Search", with: "Zach"
        click_button "Filter results"
        expect(page.all('.client-row').length).to eq 1
        expect(page.all('.client-row')[0]).to have_text(zach_prep_ready_for_call.preferred_name)
        click_link "Clear"

        within ".filter-form" do
          fill_in_tagify '.multi-select-vita-partner', "Alan's Org"

          click_button "Filter results"
          expect(page).to have_text("Alan's Org")
        end

        expect(page.all('.client-row').length).to eq 1
        expect(page.all('.client-row')[0]).to have_text alan_intake_in_progress.preferred_name
        click_link "Clear"

        within ".filter-form" do
          fill_in_tagify '.multi-select-vita-partner', "Alan's Org"
          select "2020", from: "year"
          select "Mona Mandarin", from: "assigned_user_id"
          select "Ready for prep", from: "status"
          fill_in "Search", with: "Zach"

          click_button "Filter results"
          expect(page).to have_text("Alan's Org")
          expect(page).to have_select("year", selected: "2020")
          expect(page).to have_select("assigned_user_id", selected: "Mona Mandarin")
          expect(page).to have_select("status", selected: "Ready for prep")

          # reload page and filters persist
          visit hub_clients_path
          expect(page).to have_text("Alan's Org")
          expect(page).to have_select("year", selected: "2020")
          expect(page).to have_select("assigned_user_id", selected: "Mona Mandarin")
          expect(page).to have_select("status", selected: "Ready for prep")

          visit hub_assigned_clients_path
          expect(page).not_to have_text("Alan's Org")
          expect(page).to have_select("year", selected: "")
          expect(page).to have_select("status", selected: "")

          fill_in_tagify '.multi-select-vita-partner', "Some Other Org"
          select "2019", from: "year"
          select "Not filing", from: "status"
          fill_in "Search", with: "Bob"
          click_button "Filter results"
          # Filters persist after submitting with filters
          expect(page).to have_text("Some Other Org")
          expect(page).to have_select("year", selected: "2019")
          expect(page).to have_select("status", selected: "Not filing")

          # Filters persist when visiting the page directly
          visit hub_assigned_clients_path
          expect(page).to have_text("Some Other Org")
          expect(page).to have_select("year", selected: "2019")
          expect(page).to have_select("status", selected: "Not filing")

          # Can navigate to another dashboard and see that pages persisted filters again.
          visit hub_clients_path
          expect(page).to have_text("Alan's Org")
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
          expect(page.all('.client-row').length).to eq 3

          # Sort one direction
          click_link "sort-preferred_name"
          expect(page.all('.client-row').length).to eq 3 # make sure filter is retained
          expect(page.all('.client-row')[0]).to have_text(marty_ctc.preferred_name)
          expect(page.all('.client-row')[1]).to have_text(patty_prep_ready_for_call.preferred_name)
          expect(page.all('.client-row')[2]).to have_text(zach_prep_ready_for_call.preferred_name)

          # Sort opposite direction
          click_link "sort-preferred_name"
          expect(page.all('.client-row').length).to eq 3 # make sure filter is retained
          expect(page.all('.client-row')[2]).to have_text(marty_ctc.preferred_name)
          expect(page.all('.client-row')[1]).to have_text(patty_prep_ready_for_call.preferred_name)
          expect(page.all('.client-row')[0]).to have_text(zach_prep_ready_for_call.preferred_name)

          #zach, betty, patty (oldest to youngest created at)
          click_link "sort-created_at"
          expect(page.all('.client-row').length).to eq 3 # make sure filter is retained
          expect(page.all('.client-row')[0]).to have_text(marty_ctc.preferred_name)
          expect(page.all('.client-row')[1]).to have_text(zach_prep_ready_for_call.preferred_name)
          expect(page.all('.client-row')[2]).to have_text(patty_prep_ready_for_call.preferred_name)

          click_link "sort-created_at"
          expect(page.all('.client-row').length).to eq 3 # make sure filter is retained
          expect(page.all('.client-row')[0]).to have_text(patty_prep_ready_for_call.preferred_name)
          expect(page.all('.client-row')[1]).to have_text(zach_prep_ready_for_call.preferred_name)
          expect(page.all('.client-row')[2]).to have_text(marty_ctc.preferred_name)
        end
        within ".filter-form" do
          click_link "Clear"
        end
        within ".client-table" do
          expect(page.all('.client-row').length).to eq 5
        end

        # sort by state of residence ASC
        click_link "sort-state_of_residence"
        expect(page.all('.client-row').length).to eq 5 # make sure filter is retained
        expect(page.all('.client-row')[0]).to have_text(patty_prep_ready_for_call.preferred_name) # AL
        expect(page.all('.client-row')[1]).to have_text(alan_intake_in_progress.preferred_name) # CA
        expect(page.all('.client-row')[2]).to have_text(marty_ctc.preferred_name) # ME
        expect(page.all('.client-row')[3]).to have_text(betty_intake_in_progress.preferred_name) # TX
        expect(page.all('.client-row')[4]).to have_text(zach_prep_ready_for_call.preferred_name) # WI

        # sort by state of residence DESC
        click_link "sort-state_of_residence"
        expect(page.all('.client-row').length).to eq 5 # make sure filter is retained
        expect(page.all('.client-row')[0]).to have_text(zach_prep_ready_for_call.preferred_name)

        # return to default sort order
        click_link "sort-last_outgoing_communication_at"
        expect(page.all('.client-row')[0]).to have_text(alan_intake_in_progress.preferred_name)
        expect(page.all('.client-row')[0]).to have_text("7 days")
        expect(page.all('.client-row')[0]).to have_css(".text--red-bold")
        expect(page.all('.client-row')[1]).to have_text(zach_prep_ready_for_call.preferred_name)
        expect(page.all('.client-row')[1]).to have_css(".text--red-bold")
        expect(page.all('.client-row')[1]).to have_text("4 days")
        expect(page.all('.client-row')[2]).to have_text(patty_prep_ready_for_call.preferred_name)
        expect(page.all('.client-row')[2]).to have_text("1 day")
        expect(page.all('.client-row')[3]).to have_text(marty_ctc.preferred_name)
        expect(page.all('.client-row')[3]).to have_text("1 day")
        expect(page.all('.client-row')[4]).not_to have_css(".text--red-bold")
        expect(page.all('.client-row')[4]).to have_text(betty_intake_in_progress.preferred_name)
        expect(page.all('.client-row')[4]).to have_text("1 day")

        # sort by "waiting on" puts updates at the bottom and orders responses by first_unanswered_incoming_interaction_at
        click_link "sort-first_unanswered_incoming_interaction_at"
        expect(page.all('.client-row')[0]).to have_text(alan_intake_in_progress.preferred_name)
        expect(page.all('.client-row')[0]).to have_text("Response")
        expect(page.all('.client-row')[1]).to have_text(betty_intake_in_progress.preferred_name)
        expect(page.all('.client-row')[1]).to have_text("Response")
        expect(page.all('.client-row')[2]).to have_text(patty_prep_ready_for_call.preferred_name)
        expect(page.all('.client-row')[2]).to have_text("Response")
        expect(page.all('.client-row')[3]).to have_text(marty_ctc.preferred_name)
        expect(page.all('.client-row')[3]).to have_text("Response")
        expect(page.all('.client-row')[4]).to have_text(zach_prep_ready_for_call.preferred_name)
        expect(page.all('.client-row')[4]).to have_text("Update")

        # sort by "waiting on" in reverse puts updates at the top
        click_link "sort-first_unanswered_incoming_interaction_at"
        expect(page.all('.client-row')[0]).to have_text("Update")
        expect(page.all('.client-row')[1]).to have_text("Response")

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
          expect(page.all('.client-row').length).to eq 5
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
          expect(page.all('.client-row').length).to eq 5
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
          expect(page).not_to have_text(marty_ctc.preferred_name)
          expect(page).to have_text(betty_intake_in_progress.preferred_name)
          expect(page).to have_text(patty_prep_ready_for_call.preferred_name)
          expect(page).to have_text(zach_prep_ready_for_call.preferred_name)
        end

        # filter for clients who used a navigator
        within ".filter-form" do
          click_link "Clear"
          check "used_navigator"
          click_button "Filter results"
        end
        within ".client-table" do
          expect(page).not_to have_text(alan_intake_in_progress.preferred_name)
          expect(page).not_to have_text(zach_prep_ready_for_call.preferred_name)

          expect(page).to have_text(betty_intake_in_progress.preferred_name)
          expect(page).to have_text(patty_prep_ready_for_call.preferred_name)
        end

        # filter for CTC clients
        within ".filter-form" do
          click_link "Clear"
          check "ctc_client"
          click_button "Filter results"
        end
        within ".client-table" do
          expect(page).not_to have_text(alan_intake_in_progress.preferred_name)
          expect(page).not_to have_text(zach_prep_ready_for_call.preferred_name)
          expect(page).not_to have_text(betty_intake_in_progress.preferred_name)
          expect(page).not_to have_text(patty_prep_ready_for_call.preferred_name)

          expect(page).to have_text(marty_ctc.preferred_name)
        end
      end
    end
  end
end
