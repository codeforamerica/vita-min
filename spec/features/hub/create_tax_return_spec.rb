require "rails_helper"

RSpec.feature "Add a tax return for an existing client" do
  context "As an authenticated user" do
    let(:user) { create :organization_lead_user, name: "Org Lead" }
    let(:client) { create :client, vita_partner: user.role.organization, intake: create(:intake, preferred_name: "Bart Simpson") }
    let!(:tax_return2019) { create :tax_return, client: client, year: 2019 }

    before do
      login_as user
    end

    scenario "creating a tax return" do

      visit hub_client_path(id: client.id)

      expect(page).to have_text("Add tax year")
      click_on "Add tax year"

      expect(page).to have_selector("h1", text: "Add tax year for Bart Simpson")
      expect(page).to have_select("Tax year", options: (TaxReturn.filing_years - [2019]).map(&:to_s))
      select "2017", from: "Tax year"
      select "Org Lead", from: "Assigned user"
      select "Basic", from: "Certification level"
      select "Greeter - info requested", from: "Status"

      click_on "Save"

      new_tax_return = TaxReturn.last
      within "#tax-return-#{new_tax_return.id}" do
        expect(page).to have_selector(".certification-label", text: "BAS")
        expect(page).to have_text "2017"
        expect(page).to have_text "Org Lead"
        expect(page).to have_text "Greeter - info requested"
      end
      # when tax returns are created for all years, do not show Add tax year button
      create :tax_return, client: client, year: 2018
      create :tax_return, client: client, year: 2020
      visit hub_client_path(id: client.id)
      expect(page).not_to have_text "Add tax year"
    end
  end
end
