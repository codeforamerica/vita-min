require "rails_helper"

RSpec.feature "Submitting final tax filing signature" do
  let(:client) { create :client, intake: (create :intake, primary_first_name: "Martha", primary_last_name: "Mango") }
  let(:tax_return) { create :tax_return, :ready_to_sign, :with_final_tax_doc, year: 2019, client: client }
  before { login_as client, scope: :client }

  context "confirmation screen after signing" do
    context "when filing single" do
      scenario "Only requiring primary taxpayer signature" do
        visit portal_tax_return_authorize_signature_path(tax_return_id: tax_return.id)
        check "I authorize GetYourRefund to enter or generate my PIN as my signature on my tax year 2019 electronically filed income tax return."
        check "I confirm that I am MARTHA MANGO, listed as the taxpayer on this 2019 tax document."
        click_on "Submit"

        expect(page).to have_text "Thank you for submitting your final 2019 signature!"
        expect(page).to have_text "Would you like to download your final tax forms?"
        expect(page).to have_link "Download final 2019 tax forms"

        click_on "Return to welcome page"
        expect(page).to have_text("Welcome")
      end
    end

    context "when filing jointly as a couple" do
      let(:client) {
        create :client,
               intake:
                 (create :intake,
                         primary_first_name: "Martha",
                         primary_last_name: "Mango",
                         spouse_first_name: "Larry",
                         spouse_last_name: "Lime",
                         filing_joint: "yes"
                 )
      }
      let(:tax_return) { create :tax_return, :ready_to_sign, :with_final_tax_doc, year: 2019, client: client }

      before { login_as client, scope: :client }

      scenario "Submitting spouse e-file signature" do
        visit portal_tax_return_spouse_authorize_signature_path(tax_return_id: tax_return.id)

        check "I authorize GetYourRefund to enter or generate my PIN as my signature on my tax year 2019 electronically filed income tax return."
        check "I confirm that I am LARRY LIME, listed as the spouse of taxpayer MARTHA MANGO on this 2019 tax document."
        click_on "Submit"

        expect(page).to have_text "Thank you for submitting your final 2019 signature!"
        expect(page).to have_text "Would you like to download your final tax forms?"
        expect(page).to have_link "Download final 2019 tax forms"

        click_on "Return to welcome page"
        expect(page).to have_text("Welcome")
      end
    end
  end

  context "portal home after signing" do
    let(:client) {
      create :client,
             vita_partner: user.role.organization,
             intake:
               (create :intake,
                       primary_first_name: "Martha",
                       primary_last_name: "Mango",
                       spouse_first_name: "Larry",
                       spouse_last_name: "Lime",
                       filing_joint: "yes"
               )
    }
    let(:user) { create :organization_lead_user, name: "Org Lead" }

    let!(:tax_return) { create :tax_return, :ready_to_sign, :with_final_tax_doc, year: 2019, client: client }

    before { login_as client, scope: :client }

    scenario "when filing jointly" do
      visit portal_root_path
      expect(page).to have_link "Add final primary taxpayer signature for 2019"
      expect(page).to have_link "Add final spouse signature for 2019"
      expect(page).not_to have_text "Final signature added for 2019."

      click_on "Add final primary taxpayer signature for 2019"

      check "I authorize"
      check "I confirm"
      click_on "Submit"

      click_on "Return to welcome page"

      expect(page).not_to have_link "Add final primary taxpayer signature for 2019"

      click_on "Add final spouse signature for 2019"

      check "I authorize"
      check "I confirm"
      click_on "Submit"

      click_on "Return to welcome page"

      expect(page).not_to have_link "Add final spouse taxpayer signature for 2019"
      expect(page).to have_text "Final signature added for 2019"
    end

    scenario "when a unsigned document is uploaded after signing a document" do
      # signing document
      visit portal_root_path
      expect(page).to have_link "Add final primary taxpayer signature for 2019"
      expect(page).to have_link "Add final spouse signature for 2019"
      expect(page).not_to have_text "Final signature added for 2019."

      click_on "Add final primary taxpayer signature for 2019"

      check "I authorize"
      check "I confirm"
      click_on "Submit"

      click_on "Return to welcome page"

      expect(page).not_to have_link "Add final primary taxpayer signature for 2019"

      click_on "Add final spouse signature for 2019"

      check "I authorize"
      check "I confirm"
      click_on "Submit"

      click_on "Return to welcome page"

      expect(page).not_to have_link "Add final spouse taxpayer signature for 2019"
      expect(page).to have_text "Final signature added for 2019"

      # signing in as hub user and adding unsigned 8879
      login_as user
      original_document_count = client.documents.count

      visit hub_client_documents_path(client_id: client.id)

      click_on "Add document"

      attach_file "document_upload", Rails.root.join("spec", "fixtures", "attachments", "document_bundle.pdf")

      fill_in "Display name", with: "A new unsigned 8879 document"

      select "Form 8879 (Unsigned)", from: "Document type"
      select "2019", from: "Tax return"

      click_on "Save"
      expect(client.documents.count).to eq original_document_count + 1

      # returning as client to portal home
      login_as client, scope: :client

      visit portal_root_path
      expect(page).to have_link "Add final primary taxpayer signature for 2019"
      expect(page).to have_link "Add final spouse signature for 2019"
      expect(page).not_to have_text "Final signature added for 2019."

      click_on "Add final primary taxpayer signature for 2019"

      check "I authorize"
      check "I confirm"
      click_on "Submit"

      click_on "Return to welcome page"

      expect(page).not_to have_link "Add final primary taxpayer signature for 2019"

      click_on "Add final spouse signature for 2019"

      check "I authorize"
      check "I confirm"
      click_on "Submit"

      click_on "Return to welcome page"

      expect(page).not_to have_link "Add final spouse taxpayer signature for 2019"
      expect(page).to have_text "Final signature added for 2019"
    end
  end
end