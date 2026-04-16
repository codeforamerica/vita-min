require "rails_helper"

RSpec.describe "searching, sorting, and filtering clients" do
  context "as an admin user" do
    let(:user) { create :admin_user }
    let(:mona_user) { create :user, name: "Mona Mandarin" }
    let(:fake_time) { Time.utc(2024, 5, 4, 12, 0, 0) }

    before { login_as user }

    around do |example|
      Timecop.freeze(fake_time) do
        Time.use_zone(user.timezone) { example.run }
      end
    end

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
      let!(:alan_intake_in_progress) { create :client, vita_partner_id: vita_partner.id, intake: (build :intake, preferred_name: "Alan Avocado", created_at: 1.day.ago, state_of_residence: "CA"), last_outgoing_communication_at: Time.utc(2024, 4, 23), first_unanswered_incoming_interaction_at: Time.utc(2024, 4, 23), tax_returns: [(build :tax_return, :intake_in_progress, year: 2022, assigned_user: user)] }
      let!(:zach_prep_ready_for_call) { create :client, vita_partner: vita_partner_other, intake: (build :intake, preferred_name: "Zach Zucchini", created_at: 3.days.ago, state_of_residence: "WI"), last_outgoing_communication_at: Time.utc(2024, 4, 29), tax_returns: [(build :tax_return, :prep_ready_for_prep, year: 2023)] }
      let!(:patty_prep_ready_for_call) { create :client, vita_partner: vita_partner_other, intake: (build :intake, preferred_name: "Patty Banana", created_at: 1.day.ago, state_of_residence: "AL", with_incarcerated_navigator: true), last_outgoing_communication_at: Time.utc(2024, 5, 1), first_unanswered_incoming_interaction_at: Time.utc(2024, 5, 1), tax_returns: [(build :tax_return, :prep_ready_for_prep, year: 2022, assigned_user: user)] }
      let!(:betty_intake_in_progress) { create :client, vita_partner: site, intake: (build :intake, preferred_name: "Betty Banana", created_at: 2.days.ago, state_of_residence: "TX", with_general_navigator: true), last_outgoing_communication_at: Time.utc(2024, 5, 3), first_unanswered_incoming_interaction_at: Time.utc(2024, 4, 28), tax_returns: [(build :tax_return, :intake_in_progress, year: 2023, assigned_user: mona_user)] }

      before do
        zach_prep_ready_for_call.update(first_unanswered_incoming_interaction_at: nil)
        Intake.update_all(needs_to_flush_searchable_data_set_at: Time.current - 1.minute)
        Client.update_all(needs_to_flush_filterable_properties_set_at: Time.current - 1.minute)
        SearchIndexer.refresh_search_index
        SearchIndexer.refresh_filterable_properties
      end

      scenario "I can view all clients and search, sort, and filter", js: true do
        visit hub_clients_path

        expect(page).to have_text "All Clients"

        expect(page).to have_css('.client-table')
        expect(page).to have_css('.client-row', count: 4)

        # Default sort order
        expected_rows = [
          { "Name" => a_string_including(alan_intake_in_progress.preferred_name) },
          { "Name" => a_string_including(zach_prep_ready_for_call.preferred_name) },
          { "Name" => a_string_including(patty_prep_ready_for_call.preferred_name) },
          { "Name" => a_string_including(betty_intake_in_progress.preferred_name) }
        ]
        expect(table_contents(page.find('.client-table'))).to match_rows(expected_rows)

        # search for client
        fill_in "Search", with: "Zach"
        click_button "Filter results"
        sleep 0.1
        expect(page.all('.client-row').length).to eq 1
        expect(page.all('.client-row')[0]).to have_text(zach_prep_ready_for_call.preferred_name)
        click_link "Clear"

        within ".filter-form" do
          fill_in_tagify '.multi-select-vita-partner', "Alan's Org"
          click_button "Filter results"
          page_change_check("Alan's Org")
        end

        expect(page.all('.client-row').length).to eq 1
        expect(page.all('.client-row')[0]).to have_text alan_intake_in_progress.preferred_name
        click_link "Clear"

        within ".filter-form" do
          fill_in_tagify '.multi-select-vita-partner', "Alan's Org"
          select "2023", from: "year"
          select "Mona Mandarin", from: "assigned_user_id"
          select "Ready for prep", from: "status"
          fill_in "Search", with: "Zach"

          click_button "Filter results"
          page_change_check("Alan's Org")
          expect(page).to have_select("year", selected: "2023")
          expect(page).to have_select("assigned_user_id", selected: mona_user.name_with_role)
          expect(page).to have_select("status", selected: "Ready for prep")
        end

        # reload page and filters persist
        visit hub_clients_path
        page_change_check("Alan's Org")
        within ".filter-form" do
          expect(page).to have_select("year", selected: "2023")
          expect(page).to have_select("assigned_user_id", selected: mona_user.name_with_role)
          expect(page).to have_select("status", selected: "Ready for prep")
        end

        visit hub_assigned_clients_path
        sleep 0.1
        within ".filter-form" do
          expect(page).to have_select("year", selected: "")
          expect(page).to have_select("status", selected: "")

          fill_in_tagify '.multi-select-vita-partner', "Some Other Org"
          select "2022", from: "year"
          select "Not filing", from: "status"
          fill_in "Search", with: "Bob"
          click_button "Filter results"
          page_change_check("Some Other Org")
          expect(page).to have_select("year", selected: "2022")
          expect(page).to have_select("status", selected: "Not filing")
        end

        # Filters persist when visiting the page directly
        visit hub_assigned_clients_path
        within ".filter-form" do
          expect(page).to have_select("year", selected: "2022")
          expect(page).to have_select("status", selected: "Not filing")
        end

        # Can navigate to another dashboard and see that pages persisted filters again.
        visit hub_clients_path
        within ".filter-form" do
          expect(page).to have_select("year", selected: "2023")
          expect(page).to have_select("assigned_user_id", selected: mona_user.name_with_role)
          expect(page).to have_select("status", selected: "Ready for prep")
        end
        click_link "Clear"

        within ".filter-form" do
          select mona_user.name_with_role, from: "assigned_user_id"
          click_button "Filter results"
          sleep 0.1
          expect(page).to have_select("assigned_user_id", selected: mona_user.name_with_role)
        end

        expect(page.all('.client-row').length).to eq 1
        expect(page.all('.client-row')[0]).to have_text betty_intake_in_progress.preferred_name
        click_link "Clear"

        within ".filter-form" do
          select "Ready for prep", from: "status"
          click_button "Filter results"
          sleep 0.1
          expect(page).to have_select("status-filter", selected: "Ready for prep")
        end

        click_link "sort-preferred_name"
        click_link "sort-preferred_name"
        click_link "sort-created_at"
        click_link "sort-created_at"

        within ".filter-form" do
          click_link "Clear"
        end

        click_link "sort-state_of_residence"
        expected_rows = [
          { "Name" => a_string_including("Patty"), "State" => "AL" },
          { "Name" => a_string_including("Alan"), "State" => "CA" },
          { "Name" => a_string_including("Betty"), "State" => "TX" },
          { "Name" => a_string_including("Zach"), "State" => "WI" }
        ]
        expect(table_contents(page.find('.client-table'))).to match_rows(expected_rows)

        click_link "sort-last_outgoing_communication_at"
        expected_rows = [
          { "Name" => a_string_including("Alan"), "Last contact" => "9 days" },
          { "Name" => a_string_including("Zach"), "Last contact" => "5 days" },
          { "Name" => a_string_including("Patty"), "Last contact" => "3 days" },
          { "Name" => a_string_including("Betty"), "Last contact" => "1 day" }
        ]
        expect(table_contents(page.find('.client-table'))).to match_rows(expected_rows)

        click_link "sort-first_unanswered_incoming_interaction_at"
        click_link "sort-first_unanswered_incoming_interaction_at"
        expect(page.all('.client-row')[0]).to have_text("Update")
        expect(page.all('.client-row')[1]).to have_text("Response")

        within ".filter-form" do
          select "2022", from: "year"
          click_button "Filter results"
          sleep 0.1
          expect(page).to have_select("year", selected: "2022")
        end
        expect(page.all('.client-row').length).to eq 2

        fill_in "Search", with: "Banana"
        click_button "Filter results"
        sleep 0.1
        expect(page.all('.client-row').length).to eq 1
        expect(page.all('.client-row')[0]).to have_text(patty_prep_ready_for_call.preferred_name)

        click_link "Clear"

        within ".filter-form" do
          select "2022", from: "year"
          select "Ready for prep", from: "status"
          click_button "Filter results"
          sleep 0.1
        end
        expect(page.all('.client-row').length).to eq 1

        click_link "Clear"

        within ".filter-form" do
          check "assigned_to_me"
          select "Ready for prep", from: "status"
          select "2022", from: "year"
          click_button "Filter results"
          sleep 0.1
        end
        expect(page).to have_checked_field("assigned_to_me")

        within ".filter-form" do
          select "2023", from: "year"
          click_button "Filter results"
          sleep 0.1
        end
        expect(page).to have_css ".empty-clients"

        click_link "Clear"

        within ".filter-form" do
          check "greetable"
          click_button "Filter results"
          sleep 0.1
        end
        expect(page.all('.client-row').length).to eq 3

        click_link "Clear"

        within ".filter-form" do
          check "used_navigator"
          click_button "Filter results"
          sleep 0.1
        end
        expect(page.all('.client-row').length).to eq 2

        click_link "Clear"

        within ".filter-form" do
          check "ctc_client"
          click_button "Filter results"
          sleep 0.1
        end
        expect(page).not_to have_selector(".client-table")
      end
    end

    context "SLA quick filters" do
      let(:user) { create :admin_user }

      before do
        create(:client_with_intake_and_return, last_outgoing_communication_at: 0.days.ago)
        5.times { create(:client_with_intake_and_return, last_outgoing_communication_at: 2.business_days.ago) }
        3.times { create(:client_with_intake_and_return, last_outgoing_communication_at: 4.business_days.ago - 2.hours) }
        2.times { create(:client_with_intake_and_return, last_outgoing_communication_at: 8.business_days.ago) }
        create(:client_with_intake_and_return, last_outgoing_communication_at: 8.business_days.ago, tax_return_state: 'file_mailed')
      end

      scenario "using the quick filters to identify clients approaching and in breach of SLA", js: true do
        visit hub_clients_path

        expect(page).to have_text "All Clients"
        expect(page.all('.client-row').length).to eq 12

        page_change_block do
          select "Less than 1 day", from: "Last contact"
          click_on "Filter results"
        end

        page_change_block do
          expect(page.all('.client-row').length).to eq 1
          click_link "Clear"
        end

        page_change_block do
          select "4-5 day", from: "Last contact"
          click_on "Filter results"
        end

        page_change_block do
          expect(page.all('.client-row').length).to eq 3
          click_link "Clear"
        end

        page_change_block do
          select "6+ day", from: "Last contact"
          click_on "Filter results"
        end

        page_change_block do
          expect(page.all('.client-row').length).to eq 3
          click_link "Clear"
        end

        page_change_block do
          click_on "Approaching SLA"
        end

        page_change_block do
          expect(page.all('.client-row').length).to eq 3
          click_link "Clear"
        end

        page_change_block do
          click_on "Breached SLA"
        end

        page_change_block do
          expect(page.all('.client-row').length).to eq 2
          page.find('a', text: "Breached SLA").find('.clear-filter').click
        end

        page_change_block do
          expect(page.all('.client-row').length).to eq 12
        end
      end
    end
  end
end