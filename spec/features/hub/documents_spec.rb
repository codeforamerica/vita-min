require "rails_helper"

RSpec.feature "View and edit documents for a client" do
  context "As an authenticated user" do
    let(:user) { create :organization_lead_user, name: "Org Lead" }
    let(:client) { create :client, vita_partner: user.role.organization, intake: create(:intake, preferred_name: "Bart Simpson") }
    let(:tax_return_1) { create :tax_return, client: client, year: 2019 }
    let!(:document_1) { create :document, display_name: "ID.jpg", client: client, intake: client.intake, tax_return: tax_return_1, document_type: "Care Provider Statement", uploaded_by: client }
    let!(:document_2) { create :document, display_name: "W-2.pdf", client: client, intake: client.intake, tax_return: tax_return_1, document_type: "Care Provider Statement" }
    let!(:document_3) { create :document, display_name: "consent.pdf", client: client, intake: client.intake, uploaded_by: nil }

    before do
      login_as user
      create :tax_return, client: client, year: 2017
    end

    scenario "view document list and edit document attributes" do
      page.driver.header("User-Agent", "GeckoFox")

      visit hub_client_documents_path(client_id: client.id)

      expect(page).to have_selector("h1", text: "Bart Simpson")
      expect(page).to have_selector("#document-#{document_1.id}", text: "ID.jpg")
      expect(page).to have_selector("#document-#{document_1.id}", text: "Care Provider Statement")
      expect(page).to have_selector("#document-#{document_1.id}", text: "2019")
      expect(page).to have_selector("#document-#{document_1.id}", text: "Client")

      within "#document-#{document_1.id}" do
        click_on "Edit"
      end

      expect(page).to have_text("Edit Document")

      fill_in("Display name", with: "Updated Document Title")
      select("2017", from: "Tax return")
      select("Selfie", from: "Document type")

      click_on "Save"

      expect(page).to have_selector("h1", text: "Bart Simpson")
      expect(page).to have_selector("#document-#{document_1.id}", text: "Updated Document Title")
      expect(page).to have_selector("#document-#{document_1.id}", text: "2017")
      expect(page).to have_selector("#document-#{document_1.id}", text: "Selfie")
      expect(page).to have_selector("#document-#{document_3.id}", text: "Auto-generated")
    end

    scenario "uploading a document to a client's documents page" do
      original_document_count = client.documents.count

      visit hub_client_documents_path(client_id: client.id)

      click_on "Add document"

      attach_file "document_upload", Rails.root.join("spec", "fixtures", "files", "document_bundle.pdf")

      fill_in "Display name", with: "A new final document"

      select "Final Tax Document", from: "Document type"
      select "2017", from: "Tax return"

      click_on "Save"
      expect(client.documents.count).to eq original_document_count + 1

      expect(page).to have_text("Confirm Final Tax Document")
      click_on "No"

      # deletes the original document and renders new
      expect(client.documents.count).to eq original_document_count + 0

      expect(page).to have_select("Document type", selected: "Final Tax Document")
      expect(page).to have_select("Tax return", selected: "2017")
      expect(page).to have_field("Display name", with: "A new final document")
      attach_file "document_upload", Rails.root.join("spec", "fixtures", "files", "document_bundle.pdf")

      click_on "Save"

      expect(page).to have_text("Confirm Final Tax Document")
      click_on "Yes"

      within "#document-#{Document.last.id}" do
        expect(page).to have_content("2017")
        expect(page).to have_content("Final Tax Document")
        expect(page).to have_content("Org Lead")
      end
      expect(client.documents.count).to eq original_document_count + 1
    end
  end
end
