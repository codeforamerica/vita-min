require "rails_helper"

RSpec.feature "Client uploads a requested document" do
  let!(:intake) { create :intake, requested_docs_token: "1234ABCDEF" }
  scenario "client goes to the follow up documents token link without logging in", :js do
    visit "/documents/add/1234ABCDEF"

    expect(page).to have_selector("h1", text: "Your tax specialist is requesting additional documents")
    attach("document_type_upload_form[document]", Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png"))

    expect(page).to have_content("test-pattern.png")
    expect(page).to have_link("Remove")

    click_on "I'm done for now"

    expect(page).to have_text "Thank you! Your documents have been submitted."
    expect(page).to have_text "Your tax preparer will reach out with updates and any additional questions within 3 business days."

    # Re-visit token page and see that previously uploaded docs cannot be seen if not logged in
    visit "/documents/add/1234ABCDEF"

    expect(page).to have_selector("h1", text: "Your tax specialist is requesting additional documents")
    expect(page).not_to have_content("test-pattern.png")
    expect(page).not_to have_link("Remove")

    attach("document_type_upload_form[document]", Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png"))

    expect(page).to have_content("test-pattern.png")
    expect(page).to have_link("Remove")

    click_on "I'm done for now"

    expect(page).to have_text "Thank you! Your documents have been submitted."
    expect(page).to have_text "Your tax preparer will reach out with updates and any additional questions within 3 business days."
  end

  # TODO: remove this scenario when login is removed
  xscenario "client goes to the follow up documents token link while logged in", :js do
    silence_omniauth_logging do
      visit "/documents/requested-documents"
    end
    expect(page).to have_selector("h1", text: "First, let’s get some basic information.")
    OmniAuth.config.mock_auth[:idme] = omniauth_idme_success
    click_on "Sign in with ID.me"

    # Upload a follow up document using logged-in flow
    visit "/documents/requested-documents"

    expect(page).to have_selector("h1", text: "Your tax specialist is requesting additional documents")
    attach("document_type_upload_form[document]", Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png"))

    expect(page).to have_content("test-pattern.png")
    expect(page).to have_link("Remove")

    click_on "I'm done for now"

    expect(page).to have_text "Thank you! Your documents have been submitted."
    expect(page).to have_text "Your tax preparer will reach out with updates and any additional questions within 3 business days."

    # Visit token-based upload page
    visit "/documents/add/1234ABCDEF"

    expect(page).to have_selector("h1", text: "Your tax specialist is requesting additional documents")

    # Check that doc uploaded with non-token flow is not shown
    expect(page).not_to have_selector("h2", text: "test-pattern.png")

    # Check that file can be added
    attach("document_type_upload_form[document]", Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png"))

    expect(page).to have_selector("h2", text: "test-pattern.png", count: 1)

    click_on "I'm done for now"

    # Visit token-based upload page again
    visit "/documents/add/1234ABCDEF"

    # Check that doc uploaded with token flow while logged in IS shown if still logged in
    expect(page).to have_selector("h2", text: "test-pattern.png", count: 1)
    expect(page).to have_link("Remove")

    # Check that another file can be added
    attach("document_type_upload_form[document]", Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png"))

    expect(page).to have_selector("h2", text: "test-pattern.png", count: 2)

    click_on "I'm done for now"

    expect(page).to have_text "Thank you! Your documents have been submitted."
    expect(page).to have_text "Your tax preparer will reach out with updates and any additional questions within 3 business days."
  end
end
