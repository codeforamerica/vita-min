require "rails_helper"

RSpec.describe "a user editing a clients intake fields" do
  context "as an admin user" do
    let(:organization) { create(:organization) }
    let(:user) { create :admin_user }
    let(:client) {
      create :client,
             vita_partner: organization,
             intake: create(:intake, email_address: "colleen@example.com", primary_first_name: "Colleen", primary_last_name: "Cauliflower", preferred_interview_language: "es", state_of_residence: "CA", preferred_name: "Colleen Cauliflower", email_notification_opt_in: "yes", dependents: [
               create(:dependent, first_name: "Lara", last_name: "Legume", birth_date: "2007-03-06"),
             ])

    }
    before { login_as user }

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
        fill_in "Preferred full name", with: "Colly Cauliflower"
        select "Mandarin", from: "Preferred language"
        check "Married"
        check "Separated"
        fill_in "Separated year", with: "2017"
        check "Widowed"
        fill_in "Widowed year", with: "2015"
        check "Lived with spouse"
        check "Divorced"
        fill_in "Divorced year", with: "2018"

        check "Filing jointly"
        fill_in "Email", with: "hello@cauliflower.com"
        fill_in "Phone number", with: "(500) 555-0006"
        fill_in "Phone for texting", with: "500-555-0006"
        fill_in "Street address", with: "123 Garden Ln"
        fill_in "City", with: "Brassicaville"
        select "California", from: "State"
        fill_in "ZIP code", with: "95032"
        check "Opt into email notifications"
        check "Opt into sms notifications"
      end

      within "#dependent-info" do
        fill_in "Legal first name", with: "Laura"
        expect(find_field("hub_update_client_form[dependents_attributes][0][first_name]").value).to eq "Laura"
        fill_in "Legal last name", with: "Peaches"
        select "December", from: "Month"
        select "1", from: "Day"
        select "2008", from: "Year"

        click_on "Add dependent"

        new_field_id = all(".dependent-form")[1].first("input")["id"].tr('^0-9', '')
        expect(find_field("hub_update_client_form[dependents_attributes][#{new_field_id}][first_name]").value).to eq ""
        fill_in "hub_update_client_form_dependents_attributes_#{new_field_id}_first_name", with: "Paul"
        fill_in "hub_update_client_form_dependents_attributes_#{new_field_id}_last_name", with: "Pumpkin"
        select "October", from: "hub_update_client_form_dependents_attributes_#{new_field_id}_birth_date_month"
        select "31", from: "hub_update_client_form_dependents_attributes_#{new_field_id}_birth_date_day"
        select "2020", from: "hub_update_client_form_dependents_attributes_#{new_field_id}_birth_date_year"

        click_on "Add dependent"
        new_field_id = all(".dependent-form")[2].first("input")["id"].tr('^0-9', '')
        expect(find_field("hub_update_client_form[dependents_attributes][#{new_field_id}][first_name]").value).to eq ""
        fill_in "hub_update_client_form_dependents_attributes_#{new_field_id}_first_name", with: "Cranberry"
        select "November", from: "hub_update_client_form_dependents_attributes_#{new_field_id}_birth_date_month"
        select "25", from: "hub_update_client_form_dependents_attributes_#{new_field_id}_birth_date_day"
        select "2019", from: "hub_update_client_form_dependents_attributes_#{new_field_id}_birth_date_year"

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
      end

      click_on "Save"
      expect(page).to have_text("Please enter the last name of each dependent.")

      within "#dependent-info" do
        new_field_id = all(".dependent-form").last.first("input")["id"].tr('^0-9', '')
        fill_in "hub_update_client_form_dependents_attributes_#{new_field_id}_last_name", with: "Chung"
        select "2019", from: "hub_update_client_form_dependents_attributes_#{new_field_id}_birth_date_year"
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
      expect(page).to have_text "Dependents: 3"
      within "#dependents-list" do
        expect(page).to have_text "Laura Peaches"
        expect(page).to have_text "12/1/2008"
        expect(page).to have_text "Paul Pumpkin"
        expect(page).to have_text "10/31/2020"
        expect(page).to have_text "Cranberry Chung"
        expect(page).to have_text "11/25/2019"
      end
      expect(page).to have_text "hello@cauliflower.com"
      expect(page).to have_text "+15005550006"
      expect(page).to have_text "+15005550006"
      expect(page).to have_text "123 Garden Ln"
      expect(page).to have_text "Brassicaville, CA 95032"
      expect(page).to have_text "Peter Pepper"
      expect(page).to have_text "spicypeter@pepper.com"
    end

    it "creates a system note for client profile change" do
      visit hub_client_path(id: client.id)
      within ".client-profile" do
        click_on "Edit"
      end

      within "#primary-info" do
        fill_in "Preferred full name", with: "Colly Cauliflower"
      end

      click_on "Save"
      click_on "Notes"

      expect(page).to have_text "#{user.name} changed: \u2022 preferred name from Colleen Cauliflower to Colly Cauliflower"
    end
  end
end
