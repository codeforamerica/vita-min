require "rails_helper"

RSpec.feature "Submitting a spouse e-file signature" do
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

  scenario "Signing form 8879" do
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
