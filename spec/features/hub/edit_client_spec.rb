require "rails_helper"

RSpec.describe "a user editing a clients intake fields" do
  context "as an admin user" do
    let(:organization) { create(:organization, name: "Assigned Org") }
    let!(:new_site) { create(:site, name: "Other Site") }

    let(:user) { create :admin_user }
    let(:assigned_user) { create :user, role: create(:organization_lead_role, organization: organization) }
    let(:tax_return) { create :tax_return, year: 2019, assigned_user: assigned_user }
    let(:client) {
      create :client,
             vita_partner: organization,
             tax_returns: [tax_return],
             intake: create(:intake,
                            primary_ssn: "123456789",
                            spouse_ssn: "111423256",
                            primary_tin_type: "ssn",
                            spouse_tin_type: "ssn",
                            email_address: "colleen@example.com",
                            filing_joint: "yes",
                            primary_first_name: "Colleen",
                            primary_last_name: "Cauliflower",
                            preferred_interview_language: "es",
                            state_of_residence: "CA",
                            preferred_name: "Colleen Cauliflower",
                            email_notification_opt_in: "yes",
                            timezone: "America/Chicago",
                            dependents: [
                              create(:dependent, first_name: "Lara", last_name: "Legume", birth_date: "2007-03-06"),
                          ])

    }
    before { login_as user }

    scenario "if I update a clients' organization that an assigned tax return user cannot access, they are unassigned" do
      visit hub_client_path(id: client.id)

      within '.tax-return-list__assignment' do
        expect(page).to have_text assigned_user.name
      end

      within ".client-header__organization" do
        click_on "Edit"
      end

      expect(page).to have_text "Edit Organization for #{client.preferred_name}"
      expect(page).to have_text I18n.t("hub.clients.organizations.edit.warning_text_1")
      select "Other Site", from: "Organization"
      click_on "Save"

      within '.tax-return-list__assignment' do
        expect(page).not_to have_text assigned_user.name
      end
    end

    scenario "I can update available fields", js: true do
      visit hub_client_path(id: client.id)
      within ".client-profile" do
        click_on "Edit"
      end

      within "#primary-info" do
        fill_in "Preferred full name", with: "Bennet Basil"
      end

      click_on "Cancel"

      expect(page).to have_text "Colleen Cauliflower"
      expect(page).not_to have_text "Bennet Basil"

      within ".client-profile" do
        click_on "Edit"
      end

      within "#primary-info" do
        expect(find_field("hub_update_client_form_primary_first_name").value).to eq "Colleen"
        expect(find_field("hub_update_client_form_primary_last_name").value).to eq "Cauliflower"
        expect(find_field("hub_update_client_form_timezone").value).to eq "America/Chicago"
        fill_in "Preferred full name", with: "Colly Cauliflower"
        select "Mandarin", from: "Preferred language"
        select "Pacific Time (US & Canada)", from: "Timezone"

        fill_in "Email", with: "hello@cauliflower.com"
        check "Opt into email notifications"
        fill_in "Phone number", with: "(500) 555-0006"
        check "Opt into sms notifications"
        fill_in "Cell phone number", with: "500-555-0006"
        fill_in "SSN/ITIN", with: "123-45-6789"
      end

      within "#marital-status-fields" do
        check "Filing jointly"
        check "Married"
        check "Lived with spouse"
        check "Separated"
        fill_in "Separated year", with: "2017"
        check "Widowed"
        fill_in "Widowed year", with: "2015"
        check "Divorced"
        fill_in "Divorced year", with: "2018"
      end

      within "#navigator-fields" do
        check "General"
        check "Incarcerated/reentry"
        check "Unhoused"
      end

      within "#address-fields" do
        fill_in "Street address", with: "123 Garden Ln"
        fill_in "City", with: "Brassicaville"
        select "California", from: "State"
        fill_in "ZIP code", with: "95032"
      end

      within "#dependents-fields" do
        fill_in "Legal first name", with: "Laura"
        expect(find_field("hub_update_client_form[dependents_attributes][0][first_name]").value).to eq "Laura"
        fill_in "Legal last name", with: "Peaches"
        field_id = all(".dependent-form")[0].first("input")["id"].tr('^0-9', '')
        fill_in "hub_update_client_form_dependents_attributes_#{field_id}_birth_date_month", with: "12"
        fill_in "hub_update_client_form_dependents_attributes_#{field_id}_birth_date_day", with: "1"
        fill_in "hub_update_client_form_dependents_attributes_#{field_id}_birth_date_year", with: "2008"

        click_on "Add dependent"
        new_field_id = all(".dependent-form")[1].first("input")["id"].tr('^0-9', '')
        expect(find_field("hub_update_client_form[dependents_attributes][#{new_field_id}][first_name]").value).to eq ""
        fill_in "hub_update_client_form_dependents_attributes_#{new_field_id}_first_name", with: "Paul"
        fill_in "hub_update_client_form_dependents_attributes_#{new_field_id}_last_name", with: "Pumpkin"
        fill_in "hub_update_client_form_dependents_attributes_#{new_field_id}_birth_date_month", with: "10"
        fill_in "hub_update_client_form_dependents_attributes_#{new_field_id}_birth_date_day", with: "31"
        fill_in "hub_update_client_form_dependents_attributes_#{new_field_id}_birth_date_year", with: "2020"

        click_on "Add dependent"
        new_field_id = all(".dependent-form")[2].first("input")["id"].tr('^0-9', '')
        expect(find_field("hub_update_client_form[dependents_attributes][#{new_field_id}][first_name]").value).to eq ""
        fill_in "hub_update_client_form_dependents_attributes_#{new_field_id}_first_name", with: "Candice"
        fill_in "hub_update_client_form_dependents_attributes_#{new_field_id}_birth_date_month", with: "11"
        fill_in "hub_update_client_form_dependents_attributes_#{new_field_id}_birth_date_day", with: "25"
        fill_in "hub_update_client_form_dependents_attributes_#{new_field_id}_birth_date_year", with: "2019"

        click_on "Add dependent"
        new_section = all(".dependent-form")[3]
        expect(all(".dependent-form").length).to eq 4
        within new_section do
          click_on "Remove"
        end
        expect(all(".dependent-form").length).to eq 3
      end

      within "#spouse-info" do
        fill_in "Legal first name", with: "Peter"
        fill_in "Legal last name", with: "Pepper"
        fill_in "Email", with: "spicypeter@pepper.com"
        select "Social Security Number (SSN)", from: "Identification Type"
        fill_in "SSN/ITIN", with: "142-86-2222"
      end

      click_on "Save"
      expect(page).to have_text("Please enter a last name.")

      within "#dependents-fields" do
        new_field_id = all(".dependent-form").last.first("input")["id"].tr('^0-9', '')
        fill_in "hub_update_client_form_dependents_attributes_#{new_field_id}_last_name", with: "Cranberry"
      end

      click_on "Save"

      expect(page).to have_text "Colleen Cauliflower"
      expect(page).to have_text "Colly Cauliflower"
      expect(page).to have_text "Mandarin"
      expect(page).to have_text "Married"
      expect(page).to have_text "Separated 2017"
      expect(page).to have_text "Widowed 2015"
      expect(page).to have_text "Lived with spouse"
      expect(page).to have_text "Divorced 2018"
      expect(page).to have_text "Filing jointly"
      expect(page).to have_text "Pacific Time (US & Canada)"
      expect(page).to have_text "Dependents: 3", normalize_ws: true
      within "#dependents-list" do
        expect(page).to have_text "Laura Peaches"
        expect(page).to have_text "12/1/2008"
        expect(page).to have_text "Paul Pumpkin"
        expect(page).to have_text "10/31/2020"
        expect(page).to have_text "Candice Cranberry"
        expect(page).to have_text "11/25/2019"
      end
      expect(page).to have_text "Navigator type"
      expect(page).to have_text "General, Incarcerated/reentry, Unhoused"
      expect(page).to have_text "hello@cauliflower.com"
      expect(page).to have_text "+15005550006"
      expect(page).to have_text "+15005550006"
      expect(page).to have_text "123 Garden Ln"
      expect(page).to have_text "Brassicaville, CA 95032"
      expect(page).to have_text "Peter Pepper"
      expect(page).to have_text "spicypeter@pepper.com"
      within ".primary-ssn" do
        expect do
          click_on "View"
          expect(page).to have_text "123456789"
        end.to change(AccessLog, :count).by(1)
        expect(AccessLog.last.event_type).to eq "read_ssn_itin"
      end

      within ".spouse-ssn" do
        expect do
          click_on "View"
          expect(page).to have_text "142862222"
        end.to change(AccessLog, :count).by(1)
        expect(AccessLog.last.event_type).to eq "read_ssn_itin"
      end

      within ".client-profile" do
        click_on "Edit"
      end

      expect(find_field("hub_update_client_form[spouse_ssn]").value).to eq "142-86-2222"
      expect(find_field("hub_update_client_form[primary_ssn]").value).to eq "123-45-6789"
    end

    scenario "I can delete a client", js: true do
      visit hub_client_path(id: client.id)
      within ".client-profile" do
        click_on "Edit info"
      end

      page.accept_alert "Are you sure you want to delete all information associated with Colleen Cauliflower?" do
        click_on "Delete client"
      end

      expect(page).to have_text "All clients"
      expect(page).to have_text "The client has been successfully deleted"
    end

    it "creates a system note for client profile change" do
      visit hub_client_path(id: client.id)
      within ".client-profile" do
        click_on "Edit"
      end

      within "#primary-info" do
        fill_in "Preferred full name", with: "Colly Cauliflower"
        fill_in "SSN/ITIN", with: "123-45-6789"
      end

      click_on "Save"
      click_on "Notes"

      expect(changes_table_contents('.changes-table')).to match({
        "divorced" => ["unfilled", "no"],
        "lived_with_spouse" => ["unfilled", "no"],
        "married" => ["unfilled", "no"],
        "preferred_name" => ["Colleen Cauliflower", "Colly Cauliflower"],
        "separated" => ["unfilled", "no"],
        "sms_notification_opt_in" => ["unfilled", "no"],
        "widowed" => ["unfilled", "no"]
      })
    end
  end
end
