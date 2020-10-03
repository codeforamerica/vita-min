require "rails_helper"

RSpec.feature "View and edit documents for a client" do
  context "As a beta tester" do
    let(:beta_tester) { create :beta_tester }
    let(:client) { create :client, preferred_name: "Bart Simpson" }
    let!(:document_1) { create :document, display_name: "ID.jpg", client: client }
    let!(:document_2) { create :document, display_name: "W-2.pdf", client: client }
    before do
      login_as beta_tester
    end

    scenario "view document list and change a display name" do
      visit client_documents_path(client_id: client.id)

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
      visit client_documents_path(client_id: client.id)
      expect(page).to have_selector("#document-#{document_1.id}", text: "ID.jpg")

      within "#document-#{document_1.id}" do
        click_on "Edit"
      end

      expect(page).to have_selector(".form-card__title", text: "Edit Document")

      fill_in("Display Name", with: "")

      click_on "Save"

      expect(page).to have_selector("#document_display_name__errors", text: "Can't be blank.")
    end
  end
end