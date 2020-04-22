require "rails_helper"

RSpec.feature "Client uploads a requested document" do
  xscenario "client goes to the follow up documents link provided by their preparer" do
    silence_omniauth_logging do
      visit "/documents/requested-documents"
    end
    expect(page).to have_selector("h1", text: "First, let’s get some basic information.")
    OmniAuth.config.mock_auth[:idme] = omniauth_idme_success
    click_on "Sign in with ID.me"

    # TODO: remove this when we can go to the original link after sign in
    visit "/documents/requested-documents"

    expect(page).to have_selector("h1", text: "Your tax specialist is requesting additional documents")
    attach_file("document_type_upload_form_document", Rails.root.join("spec", "fixtures", "attachments", "test-pattern.png"))
    click_on "Upload"

    expect(page).to have_content("test-pattern.png")
    expect(page).to have_link("Remove")

    click_on "I'm done for now"

    expect(page).to have_text "Thank you! Your documents have been submitted."
    expect(page).to have_text "Your tax preparer will reach out with updates and any additional questions within 3 business days."
  end
end
