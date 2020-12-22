require "rails_helper"

RSpec.feature "View and edit documents for a client" do
  context "As an authenticated user" do
    let(:organization) { create :organization }
    let(:user) { create :user, role: create(:organization_lead_role, organization: organization) }
    let(:client) { create :client, vita_partner: organization, intake: create(:intake, preferred_name: "Bart Simpson") }
    let!(:document_1) { create :document, display_name: "ID.jpg", client: client, intake: client.intake }
    let!(:document_2) { create :document, display_name: "W-2.pdf", client: client, intake: client.intake }
    before do
      login_as user
    end

    scenario "view document list and change a display name" do
      visit hub_client_documents_path(client_id: client.id)

      expect(page).to have_selector("h1", text: "Bart Simpson")
      expect(page).to have_selector("#document-#{document_1.id}", text: "ID.jpg")

      within "#document-#{document_1.id}" do
        click_on "Edit"
      end

      expect(page).to have_selector(".form-card__title", text: "Edit Document")

      fill_in("Display Name", with: "Updated Document Title")

      click_on "Save"

      expect(page).to have_selector("h1", text: "Bart Simpson")
      expect(page).to have_selector("#document-#{document_1.id}", text: "Updated Document Title")
    end

    scenario "updating a document with an invalid display name" do
      visit hub_client_documents_path(client_id: client.id)
      expect(page).to have_selector("#document-#{document_1.id}", text: "ID.jpg")

      within "#document-#{document_1.id}" do
        click_on "Edit"
      end

      expect(page).to have_selector(".form-card__title", text: "Edit Document")

      fill_in("Display Name", with: "")

      click_on "Save"

      expect(page).to have_selector("#document_display_name__errors", text: "Can't be blank.")
    end

    scenario "uploading a document to a client's documents page" do
      visit hub_client_documents_path(client_id: client.id)

      attach_file "document_upload", [
        Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png"),
        Rails.root.join("spec", "fixtures", "attachments", "document_bundle.pdf"),
      ]
      click_on "Upload"

      expect(page).to have_content("test-pattern.png")
      expect(page).to have_content("document_bundle.pdf")
    end
  end
end
