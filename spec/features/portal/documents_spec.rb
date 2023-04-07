require "rails_helper"

RSpec.feature "a client on their portal" do
  let(:client) do
    create :client,
           intake: (create :intake, preferred_name: "Randall", current_step: "/en/documents/overview"),
           tax_returns: [create(:tax_return, :intake_in_progress, year: 2022)]
  end

  before do
    create :document, intake: client.intake, document_type: DocumentTypes::Identity.key, upload_path: Rails.root.join("spec", "fixtures", "files", "picture_id.jpg")
    login_as client, scope: :client
  end

  scenario "linking to next step" do
    visit portal_root_path

    click_on "Add missing documents"

    expect(page).to have_content "Here's a list of your documents"

    within '#id-docs' do
      expect(page).to have_content "ID"
      expect(page).to have_content "picture_id.jpg"
      expect(page).to have_link "add"
    end

    within '#selfie-docs' do
      expect(page).to have_content "Photo holding ID"
      expect(page).to have_content "Please add document."
      click_on "add"
    end

    expect(page).to have_content "Add a document"
    upload_file("requested_document_upload_form[upload]", Rails.root.join("spec", "fixtures", "files", "test-pattern.png"))

    expect(page).to have_content "test-pattern.png"
    click_on 'Continue'

    expect(page).to have_content "Here's a list of your documents"

    within '#selfie-docs' do
      expect(page).to have_content "Photo holding ID"
      expect(page).to have_content "test-pattern.png"
    end
  end
end
