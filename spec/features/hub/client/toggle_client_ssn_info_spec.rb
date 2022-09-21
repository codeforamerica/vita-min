require "rails_helper"

RSpec.feature "Toggle ssn display" do
  context "As an authenticated user" do
    let(:user) { create :admin_user}
    let(:client) { create(:client, intake: create(:intake, filing_joint: "yes", primary_ssn: "123456789", spouse_ssn: "444411222" )) }
    let(:client_no_ssn) { create(:client, intake: create(:intake, filing_joint: "yes")) }
    before { login_as user }

    scenario "client without ssn/itin" do
      visit hub_client_path(id: client_no_ssn)
      within(".primary-ssn") do
        expect(page).to have_text "SSN/ITIN"
        expect(page).not_to have_text "View"

        expect(page).to have_text "N/A"
      end

      within(".spouse-ssn") do
        expect(page).to have_text "SSN/ITIN"
        expect(page).not_to have_text "View"

        expect(page).to have_text "N/A"
      end
    end

    scenario "client with ssn/itin", js: true do
      visit hub_client_path(id: client)

      within(".primary-ssn") do
        expect(page).to have_text "SSN/ITIN"
        expect(page).to have_text "View"

        expect(page).not_to have_text client.intake.primary.ssn

        expect do
          click_on "View"

          expect(page).to have_text "SSN/ITIN"
          expect(page).to have_text "Hide"

          expect(page).to have_text client.intake.primary.ssn

        end.to change(AccessLog, :count).by(1)

        click_on "Hide"

        expect(page).not_to have_text client.intake.primary.ssn
      end

      within(".spouse-ssn") do
        expect(page).to have_text "SSN/ITIN"
        expect(page).to have_text "View"

        expect(page).not_to have_text client.intake.spouse.ssn

        expect do
          click_on "View"

          expect(page).to have_text "SSN/ITIN"
          expect(page).to have_text "Hide"

          expect(page).to have_text client.intake.spouse.ssn

        end.to change(AccessLog, :count).by(1)

        click_on "Hide"

        expect(page).not_to have_text client.intake.spouse.ssn
      end
    end
  end
end
