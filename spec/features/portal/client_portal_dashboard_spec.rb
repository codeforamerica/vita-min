require "rails_helper"

RSpec.feature "a client on their portal" do
  context "when a client has not yet completed onboarding and next step is a question" do
    let(:client) { create :client, intake: (create :intake, preferred_name: "Katie", current_step: "/en/questions/asset-loss") }
    before do
      login_as client, scope: :client
    end
    scenario "linking to next step" do
      visit portal_root_path
      expect(page).to have_text "Welcome back Katie!"
      expect(page).to have_link("Complete all tax questions", href: "/en/questions/asset-loss")
      expect(page).not_to have_link "Submit additional documents"
    end
  end

  context "when a client has not yet completed onboarding and next step is documents" do
    let(:client) { create :client, intake: (create :intake, preferred_name: "Randall", current_step: "/en/documents/overview") }
    before do
      login_as client, scope: :client
    end
    scenario "linking to next step" do
      visit portal_root_path
      expect(page).to have_text "Welcome back Randall!"
      expect(page).to have_link("Submit remaining tax documents", href: "/en/documents/overview")
      expect(page).not_to have_link "Submit additional documents"

    end
  end

  context "a client with tax returns ready that have actions to take" do
    let(:client) { create :client, intake: (create :intake, preferred_name: "Martha", primary_first_name: "Martha", primary_last_name: "Mango", filing_joint: "yes") }
    let(:tax_return2019) { create :tax_return, :ready_to_sign, year: 2019, client: client }
    let(:tax_return2018) { create :tax_return, :ready_to_file_solo, year: 2018, client: client }
    before do
      create :document, display_name: "Another 8879", document_type: DocumentTypes::UnsignedForm8879.key, upload_path: Rails.root.join("spec", "fixtures", "attachments", "test-pdf.pdf"), tax_return: tax_return2019, client: tax_return2019.client
      create :tax_return, year: 2017, client: client
      create :document, document_type: DocumentTypes::FinalTaxDocument.key, tax_return: tax_return2019, client: tax_return2019.client
      create :document, document_type: DocumentTypes::FinalTaxDocument.key, display_name: "Some final tax document", tax_return: tax_return2018, client: tax_return2018.client
      create :document, document_type: DocumentTypes::FinalTaxDocument.key, display_name: "Another final tax document", tax_return: tax_return2018, client: tax_return2018.client
      login_as client, scope: :client
    end

    scenario "viewing their tax return statuses", :js do
      visit portal_root_path
      expect(page).to have_text "Welcome back Martha!"

      expect(page).to have_text "2019 tax documents"
      expect(page).to have_text "2018 tax documents"
      expect(page).to have_text "2017 tax documents"

      within "#tax-year-2019" do
        expect(page).to have_link "View or download Another 8879"
        expect(page).to have_link "View or download " + tax_return2019.unsigned_8879s.first.display_name

        expect(page).to have_link "View or download final 2019 tax document"
        expect(page).to have_link "Submit primary taxpayer signature"
        expect(page).to have_link "Submit spouse signature"
      end

      within "#tax-year-2018" do
        expect(page).to have_link "View or download signed form 8879"
        expect(page).to have_link "View or download Some final tax document"
        expect(page).to have_link "View or download Another final tax document"
        expect(page).not_to have_link "Submit primary taxpayer signature"
      end

      within "#tax-year-2017" do
        expect(page).to have_text "No documents ready to review yet - check back later."
      end
      expect(client.documents.where(document_type: "Other").length).to eq 0

      click_link "Submit additional documents"
      expect(page).to have_text "Please share any additional documents."

      attach("requested_document_upload_form[document]", Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png"))
      expect(page).to have_content("test-pattern.png")

      expect(client.documents.where(document_type: "Other").length).to eq 1
      page.accept_alert 'Are you sure you want to remove "test-pattern.png"?' do
        click_on "Remove"
      end

      expect(page).to have_text "Please share any additional documents."
      expect(client.documents.where(document_type: "Other").length).to eq 0

      click_on "Continue"
      expect(page).to have_text "Welcome back"
      click_on "Submit additional documents"

      expect(page).not_to have_content("test-pattern.png")

      expect(page).to have_text "Please share any additional documents"

      click_on "Go back"
      expect(page).to have_text "Welcome back"
    end
  end
end
