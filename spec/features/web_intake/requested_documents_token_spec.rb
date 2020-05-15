require "rails_helper"

RSpec.feature "Client uploads a requested document" do
  let!(:intake) { create :intake, requested_docs_token: "1234ABCDEF" }
  scenario "client goes to the follow up documents token link without logging in", :js do
    visit "/documents/add/1234ABCDEF"

    expect(page).to have_selector("h1", text: "Your tax specialist is requesting additional documents")
    expect(page).to have_button("Continue", disabled: true)
    attach("requested_document_upload_form[document]", Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png"))


    expect(page).to have_content("test-pattern.png")
    expect(page).to have_link("Remove")

    click_on "Continue"

    expect(page).to have_text "Thank you! Your documents have been submitted."
    expect(page).to have_text "Your tax preparer will reach out with updates and any additional questions within 3 business days."

    # Re-visit token page and see that previously uploaded docs cannot be seen if not logged in
    visit "/documents/add/1234ABCDEF"

    expect(page).to have_selector("h1", text: "Your tax specialist is requesting additional documents")
    expect(page).not_to have_content("test-pattern.png")
    expect(page).not_to have_link("Remove")

    attach("requested_document_upload_form[document]", Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png"))

    expect(page).to have_content("test-pattern.png")
    expect(page).to have_link("Remove")

    click_on "Continue"

    expect(page).to have_text "Thank you! Your documents have been submitted."
    expect(page).to have_text "Your tax preparer will reach out with updates and any additional questions within 3 business days."
  end

  scenario "client goes to the follow up documents link and does not finish the requested docs flow" do
    visit "/documents/add/1234ABCDEF"

    expect(page).to have_selector("h1", text: "Your tax specialist is requesting additional documents")
    expect(page).to have_button("Continue", disabled: true)

    visit "/questions/job-count"
    expect(current_path).to eq("/questions/welcome")
  end
end
