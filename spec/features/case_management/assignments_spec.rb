require "rails_helper"

RSpec.feature "Assign a user to a tax return" do
  context "As a beta tester" do
    let(:vita_partner) { create :vita_partner}
    let(:logged_in_user) { create :beta_tester, vita_partner: vita_partner }
    let!(:user_to_assign) { create :beta_tester, name: "Lucille 2", vita_partner: vita_partner }
    let(:client) { create :client, vita_partner: vita_partner }
    let!(:tax_return_to_assign) { create :tax_return, year: 2019, client: client }
    let!(:another_tax_return) { create :tax_return, year: 2018, client: client }

    before do
      login_as logged_in_user
    end

    scenario "logged in user can assign another user to a tax return" do
      visit case_management_clients_path

      within "#tax-return-#{tax_return_to_assign.id}" do
        click_on "Assign"
      end

      select "Lucille 2", from: "Assign to"
      click_on "Save"

      expect(page).to have_selector("h1", text: "All clients")
      within "#tax-return-#{tax_return_to_assign.id}" do
        expect(page).to have_text "Lucille 2"
      end
    end
  end
end