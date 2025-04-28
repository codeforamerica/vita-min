require "rails_helper"

RSpec.feature "Add a tax return for an existing client" do
  context "As an authenticated user" do
    let(:user) { create :organization_lead_user, name: "Org Lead" }
    let(:client) { create :client, vita_partner: user.role.organization, intake: build(:intake, preferred_name: "Bart Simpson") }
    let!(:tax_return2020) { create :tax_return, client: client, year: 2020 }

    let(:fake_current_tax_year) { 2023 }
    let(:fake_time) { DateTime.parse("2024-04-14") }

    before do
      allow(Rails.application.config).to receive(:gyr_current_tax_year).and_return(fake_current_tax_year)
      login_as user
    end

    around do |example|
      Timecop.freeze(fake_time) do
        example.run
      end
    end

    scenario "creating a tax return" do
      skip "Skipping this test for now"
      visit hub_client_path(id: client.id)

      expect(page).to have_text("Add tax year")
      click_on "Add tax year"

      expect(page).to have_selector("h1", text: "Add tax year for Bart Simpson")
      expect(page).to have_select("Tax year", options: (MultiTenantService.gyr.filing_years - [2020]).map(&:to_s))
      select "2021", from: "Tax year"
      select "Org Lead", from: "Assigned user"
      select "Basic", from: "Certification level"
      select "Greeter - info requested", from: "Status"

      click_on "Save"

      new_tax_return = TaxReturn.last
      within "#tax-return-#{new_tax_return.id}" do
        expect(page).to have_selector(".certification-label", text: "BAS")
        expect(page).to have_text "2021"
        expect(page).to have_text "Org Lead"
        expect(page).to have_text "Greeter - info requested"
      end
    end

    context "when there are no more tax return years to create objects for" do
      before do
        # 2020 already created above
        create :tax_return, client: client, year: 2021
        create :tax_return, client: client, year: 2022
        create :gyr_tax_return, client: client
      end

      scenario "it does not show the button on the client show page" do
        # when tax returns are created for all years, do not show Add tax year button
        visit hub_client_path(id: client.id)
        expect(page).not_to have_text "Add tax year"
      end
    end
  end
end
