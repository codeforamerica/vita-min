require "rails_helper"

RSpec.feature "Toggle bank account info" do
  context "As an authenticated user" do
    let(:user) { create :admin_user}
    let(:client) { create(:client, intake: create(:intake, :with_banking_details)) }
    let(:client_no_bank) { create(:client, intake: create(:intake)) }
    before { login_as user }

    scenario "client without bank account info" do
      visit hub_client_path(id: client_no_bank)
      within(".client-bank-account-info") do
        expect(page).to have_text "Refund Payment Info"
        expect(page).not_to have_text "View"

        expect(page).to have_text "No bank account info provided."
      end
    end

    scenario "client with bank account info", js: true do
      visit hub_client_path(id: client)

      within(".client-bank-account-info") do
        expect(page).to have_text "Refund Payment Info"
        expect(page).to have_text "View"

        expect(page).to have_text "Account type"
        expect(page).to have_text "Account number"
        expect(page).to have_text "Routing number"
        expect(page).not_to have_text client.intake.bank_account_number
        expect(page).not_to have_text client.intake.bank_routing_number
        expect(page).not_to have_text client.intake.bank_account_type

        expect do
          click_on "View"

          expect(page).to have_text "Account type"
          expect(page).to have_text "Account number"
          expect(page).to have_text "Routing number"
          expect(page).to have_text client.intake.bank_account_number
          expect(page).to have_text client.intake.bank_routing_number
          expect(page).to have_text client.intake.bank_account_type.titleize
        end.to change(AccessLog, :count).by(1)

        click_on "Hide"

        expect(page).not_to have_text client.intake.bank_account_number
        expect(page).not_to have_text client.intake.bank_routing_number
        expect(page).not_to have_text client.intake.bank_account_type
      end
    end
  end
end
