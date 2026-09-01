require "rails_helper"

RSpec.describe "a user viewing a client" do
  context "as an admin user" do
    let(:created_at) { Time.now }
    let(:user) { create :admin_user }
    let(:intake) { build(:intake, :with_contact_info) }
    let!(:client) { create :client, vita_partner: (build :organization), intake: intake, tax_returns: [build(:tax_return, certification_level: "advanced", year: 2019)], created_at: created_at }
    let(:tax_return) { client.tax_returns.first }
    let!(:other_vita_partner) { create :site, name: "Tax Help Test" }
    before do
      login_as user
    end

    scenario "can view and update client organization", js: true do
      visit hub_client_path(id: client.id)
      within ".client-header" do
        expect(page).to have_text client.vita_partner.name
        click_on "Edit"
      end
      expect(page.current_path).to eq edit_organization_hub_client_path(id: client.id)
      expect(page).to have_text "Edit Organization for #{client.preferred_name}"
      expect(page).to have_text "Organization"
      fill_in_tagify '.select-vita-partner', other_vita_partner.name
      click_on "Save"
      within ".client-header" do
        expect(page).to have_text other_vita_partner.name
      end
    end

    scenario "can toggle client flag" do
      visit hub_client_path(id: client.id)
      within ".client-header" do
        check "Flag"
        expect(page).to have_field("toggle-flag", checked: true)
        uncheck "Flag"
        expect(page).to have_field("toggle-flag", checked: false)
      end
    end

    scenario "can view and update tax return certification type" do
      visit hub_client_path(id: client.id)
      within "#tax-return-#{tax_return.id}" do
        expect(page).to have_text("ADV")
        expect(page).not_to have_css(".tax-return-inline-form")
        # change from advanced to basic
        click_on("ADV")
        expect(page).to have_css(".tax-return-inline-form")
        select "Basic", from: "Certification"
        click_button("button")
        expect(page).to have_text("BAS")
        expect(page).not_to have_css(".tax-return-inline-form")
        click_on "BAS"
        select "Foreign Student", from: "Certification"
        click_button("button")
        expect(page).to have_text("FS")
        expect(page).not_to have_css(".tax-return-inline-form")
      end
    end

    context "for a client with an archived 2021 GYR intake" do
      let(:intake) { nil }
      let!(:archived_intake) { create(:archived_2021_gyr_intake, client: client, filing_joint: 'yes') }
      let!(:archived_dependent) { create(:archived_2021_dependent, intake: archived_intake) }

      it "can view intake information" do
        visit hub_client_path(id: client.id)
        expect(page).to have_content(archived_intake.preferred_name)
        expect(page).to have_content(archived_dependent.full_name)
      end
    end

    context "for a client with an archived 2021 CTC intake" do
      let(:intake) { nil }
      let!(:archived_intake) { create(:archived_2021_ctc_intake, client: client) }
      let!(:archived_dependent_1) { create(:archived_2021_dependent, intake: archived_intake, relationship: 'daughter') }
      let!(:archived_dependent_2) { create(:archived_2021_dependent, intake: archived_intake, relationship: 'other') }
      let!(:archived_bank_account) { create(:archived_2021_bank_account, intake: archived_intake) }

      it "can view intake information" do
        visit hub_client_path(id: client.id)
        expect(page).to have_content(archived_intake.preferred_name)
        expect(page).to have_content(archived_dependent_1.full_name)
        expect(page).to have_content(archived_dependent_2.full_name)
        expect(page).not_to have_content(archived_bank_account.bank_name)
        expect(page).to have_content("Primary Prior Year (2020) AGI")
      end
    end

    context "for a client with an archived 2022 GYR intake" do
      before do
        intake.update(product_year: 2022)
      end

      it "will show a banner indicating the client is archived but will still show intake information" do
        visit hub_client_path(id: client.id)

        expect(page).to have_content I18n.t("hub.archived_client_warning", year: 2022)
        expect(page).to have_content(intake.preferred_name)
      end
    end

    context "for a client that was accidentally disassociated from its intake due to a bug in march 2022" do
      let(:intake) { nil }
      let(:created_at) { Date.parse('2022-03-11') }

      it "shows a warning" do
        visit hub_client_path(id: client.id)
        expect(page).to have_content("the client's information could not be found due to an error")
        expect(page).not_to have_content(I18n.t("views.shared.tax_return_list.add_tax_year"))
      end
    end
  end

  context "user without admin access, but is coalition lead for client organization" do
    let(:coalition) { create :coalition }
    let(:user) { create :coalition_lead_user, role: create(:coalition_lead_role, coalition: coalition) }
    let(:first_org) { create :organization, coalition: coalition }
    let(:primary_ssn) { "1112223333" }
    let(:client) { create :client, vita_partner: first_org, intake: build(:intake, :with_contact_info, primary_ssn: primary_ssn) }
    let!(:intake_with_ssn_match) { create :intake, primary_consented_to_service: "yes", primary_ssn: primary_ssn, client: create(:client, :with_gyr_return, tax_return_state: "intake_ready") }
    let!(:previous_year_intake_with_ssn_dob_match) { create :intake, product_year: Rails.configuration.product_year - 1, primary_consented_to_service: "yes", primary_ssn: primary_ssn, primary_birth_date: client.intake.primary_birth_date, client: create(:client, :with_gyr_return, tax_return_state: "prep_ready_for_prep") }
    let!(:second_org) { create :organization, coalition: coalition }
    before { login_as user }

    context "navigation bar" do
      scenario "returns to all clients", :js do
        visit hub_client_path(id: client.id)
        click_on("All Clients")

        expect(current_path).to eq(hub_clients_path)
        expect(page).to have_selector(".selected", text: "All Clients")
      end

      scenario "returns to user's profile", :js do
        visit hub_client_path(id: client.id)
        click_on(user.name)

        expect(current_path).to eq(hub_user_profile_path)
        expect(page).to have_selector(".selected", text: user.name)
      end

      scenario "returns to user's clients", :js do
        visit hub_client_path(id: client.id)
        click_on("My Clients")

        expect(current_path).to eq(hub_assigned_clients_path)
        expect(page).to have_selector(".selected", text: "My Clients")
      end
    end

    scenario "can view and update client organization", js: true do
      visit hub_client_path(id: client.id)
      within ".client-header" do
        expect(page).to have_text client.vita_partner.name
        click_on "Edit"
      end
      expect(page.current_path).to eq edit_organization_hub_client_path(id: client.id)
      expect(page).to have_text "Edit Organization for #{client.preferred_name}"
      expect(page).to have_text "Organization"
      fill_in_tagify '.select-vita-partner', second_org.name
      click_on "Save"
      within ".client-header" do
        expect(page).to have_text second_org.name
      end
    end

    scenario "can view potential duplicate intakes" do
      visit hub_client_path(id: client.id)
      expect(client.intake.primary.ssn).to eq primary_ssn

      within ".client-header" do
        expect(page).to have_text(I18n.t('hub.has_duplicates'))
        expect(page).to have_text "GYR: ##{intake_with_ssn_match.client.id}"
        click_on "##{intake_with_ssn_match.client.id}"
      end

      expect(page.current_path).to eq hub_client_path(id: intake_with_ssn_match.client.id)
      expect(intake_with_ssn_match.primary_ssn).to eq primary_ssn
    end

    scenario "can view potential previous year intakes" do
      visit hub_client_path(id: client.id)
      expect(client.intake.primary.ssn).to eq primary_ssn

      within ".client-header" do
        expect(page).to have_text(I18n.t('hub.has_previous_year_intakes'))
        expect(page).to have_text "##{previous_year_intake_with_ssn_dob_match.client.id}"
        click_on "##{previous_year_intake_with_ssn_dob_match.client.id}"
      end

      expect(page.current_path).to eq hub_client_path(id: previous_year_intake_with_ssn_dob_match.client.id)
      expect(previous_year_intake_with_ssn_dob_match.primary_ssn).to eq primary_ssn
    end
  end
end
