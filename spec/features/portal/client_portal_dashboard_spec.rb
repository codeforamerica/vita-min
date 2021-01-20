require "rails_helper"

RSpec.feature "a client on their portal" do
  let(:client) { create :client, intake: (create :intake, primary_first_name: "Martha", primary_last_name: "Mango", filing_joint: "yes") }

  before do
    tax_return2019 = create :tax_return, :ready_to_sign, year: 2019, client: client
    tax_return2018 = create :tax_return, :ready_to_sign, :ready_to_file_solo, year: 2018, client: client
    create :tax_return, year: 2017, client: client
    create :document, document_type: DocumentTypes::FinalTaxDocument.key, tax_return: tax_return2019, client: tax_return2019.client
    create :document, document_type: DocumentTypes::FinalTaxDocument.key, display_name: "Some final tax document", tax_return: tax_return2018, client: tax_return2018.client
    create :document, document_type: DocumentTypes::FinalTaxDocument.key, display_name: "Another final tax document", tax_return: tax_return2018, client: tax_return2018.client
    login_as client, scope: :client
  end

  scenario "viewing their tax return statuses" do
    visit portal_root_path
    expect(page).to have_text "Welcome back, Martha Mango"

    expect(page).to have_text "2019 tax documents"
    expect(page).to have_text "2018 tax documents"
    expect(page).to have_text "2017 tax documents"

    within "#tax-year-2019" do
      expect(page).to have_link "View/download form 8879"
      expect(page).to have_link "View/download final 2019 tax document"
      expect(page).to have_link "Submit primary taxpayer signature"
      expect(page).to have_link "Submit spouse signature"
    end

    within "#tax-year-2018" do
      expect(page).to have_link "View/download signed form 8879"
      expect(page).to have_link "View/download Some final tax document"
      expect(page).to have_link "View/download Another final tax document"
      expect(page).not_to have_link "Submit primary taxpayer signature"
    end

    within "#tax-year-2017" do
      expect(page).to have_text "No documents ready to review yet - check back later."
    end
  end
end
