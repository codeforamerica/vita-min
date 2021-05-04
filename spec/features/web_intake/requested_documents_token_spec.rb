require "rails_helper"

RSpec.feature "Client uploads a requested document" do
  let!(:intake) { create :intake, requested_docs_token: "1234ABCDEF" }

  xscenario "client goes to the follow up documents token link", :js do
    visit "/documents/add/1234ABCDEF"

    expect(page).to have_selector("h1", text: "Your tax specialist is requesting additional documents")
    expect(page).to have_button("Continue", disabled: true)
    attach("requested_document_upload_form[document]", Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png"))


    expect(page).to have_content("test-pattern.png")
    page.accept_confirm { click_link("Remove") }

    expect(page).not_to have_content("test-pattern.png")
    attach("requested_document_upload_form[document]", Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png"))
    click_on "Continue"

    expect(current_path).to eq(root_path)
    expect(page).to have_text "Thank you! Your documents have been submitted. If you have additional documents to share, please follow the link from your tax specialist to add more."

    # Re-visit token page and see that previously uploaded docs cannot be seen if not logged in
    visit "/documents/add/1234ABCDEF"

    expect(page).to have_selector("h1", text: "Your tax specialist is requesting additional documents")
    expect(page).not_to have_content("test-pattern.png")
    expect(page).not_to have_link("Remove")

    attach("requested_document_upload_form[document]", Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png"))

    expect(page).to have_content("test-pattern.png")
    expect(page).to have_link("Remove")

    click_on "Continue"

    expect(page).to have_text "Thank you! Your documents have been submitted. If you have additional documents to share, please follow the link from your tax specialist to add more."
  end

  scenario "client goes to the follow up documents link and does not finish the requested docs flow" do
    visit "/documents/add/1234ABCDEF"

    expect(page).to have_selector("h1", text: "Your tax specialist is requesting additional documents")
    expect(page).to have_link("Continue")

    visit "/questions/job-count"
    expect(current_path).to eq(new_portal_client_login_path)
  end

  scenario "partner goes to multiple documents link and attaches doc to last intake", :js do
    second_intake = create(:intake, requested_docs_token: "A1B2C3D4", client: (create :client))
    visit "/documents/add/#{intake.requested_docs_token}"
    visit "/documents/add/#{second_intake.requested_docs_token}"
    expect(page).to have_selector("h1", text: "Your tax specialist is requesting additional documents")

    attach("requested_document_upload_form[document]", Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png"))
    expect(page).to have_content("test-pattern.png")
    click_on "Continue"

    expect(intake.client.documents.count).to eq(0)
    expect(second_intake.client.documents.count).to eq(1)
  end
end
