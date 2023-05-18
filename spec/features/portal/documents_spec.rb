require "rails_helper"

RSpec.feature "a client on their portal" do
  context "joint filer" do
    let(:tax_return) { create(:tax_return, :intake_ready, year: 2022) }
    let(:client) do
      create :client,
             intake: (create :intake, preferred_name: "Randall", completed_at: 10.minutes.ago, filing_joint: "yes"),
             tax_returns: [tax_return]
    end

    before do
      create :document, client: client, document_type: DocumentTypes::Identity.key, upload_path: Rails.root.join("spec", "fixtures", "files", "picture_id.jpg")
      create :document, client: client, tax_return: tax_return, document_type: DocumentTypes::FinalTaxDocument.key, upload_path: Rails.root.join("spec", "fixtures", "files", "picture_id.jpg")
      login_as client, scope: :client
    end

    scenario "linking to next step" do
      visit portal_root_path

      click_on I18n.t('portal.portal.home.document_link.view_documents')

      expect(page).to have_content "Here's a list of your documents"

      within '#id-docs' do
        expect(page).to have_content "Photo ID"
        expect(page).to have_content "picture_id.jpg"
        expect(page).to have_link "add"
        expect(page).to have_content "Please add documents for you and your spouse."
        click_on "add"
      end

      expect(page).to have_content "Add a document"
      upload_file("portal_document_upload_form[upload]", Rails.root.join("spec", "fixtures", "files", "combined-test-pdf.pdf"))

      expect(page).to have_content "combined-test-pdf.pdf"
      click_on 'Continue'

      expect(page).to have_content "Here's a list of your documents"

      within '#id-docs' do
        expect(page).to have_content "Photo ID"
        expect(page).to have_content "picture_id.jpg"
        expect(page).to have_content "combined-test-pdf.pdf"
        expect(page).not_to have_content "Please add documents for you and your spouse."
      end

      within '#selfie-docs' do
        expect(page).to have_content "Photo Holding ID"
        expect(page).to have_content "Please add document."
        click_on "add"
      end

      expect(page).to have_content "Add a document"
      upload_file("portal_document_upload_form[upload]", Rails.root.join("spec", "fixtures", "files", "test-pattern.png"))

      expect(page).to have_content "test-pattern.png"
      click_on 'Continue'

      expect(page).to have_content "Here's a list of your documents"

      within '#selfie-docs' do
        expect(page).to have_content "Photo Holding ID"
        expect(page).to have_content "test-pattern.png"
        expect(page).to have_content "Please add documents for you and your spouse."
      end

      within '#final-tax-return-docs' do
        expect(page).to have_content "2022 Final Tax Document"
      end
    end
  end
end
