require "rails_helper"

RSpec.feature "Submitting a primary e-file signature" do
  let(:client) { create :client, intake: (create :intake, primary_first_name: "Martha", primary_last_name: "Mango") }
  let(:tax_return) { create :tax_return, year: 2019, client: client }
  before {
    create :document,
           document_type: DocumentTypes::UnsignedForm8879.key,
           tax_return: tax_return,
           client: tax_return.client,
           upload_path:  Rails.root.join("spec", "fixtures", "attachments", "test-pdf.pdf")
    login_as client, scope: :client
  }

  scenario "Signing form 8879" do
    visit portal_tax_return_authorize_signature_path(tax_return_id: tax_return.id)
    check "I authorize GetYourRefund to enter or generate my PIN as my signature on my tax year 2019 electronically filed income tax return."
    check "I confirm that I am MARTHA MANGO, listed as the taxpayer on this 2019 tax document."
    click_on "Submit"

    expect(page).to have_text("Successfully signed 2019 tax form!")
    expect(page).to have_text("Welcome")
  end
end