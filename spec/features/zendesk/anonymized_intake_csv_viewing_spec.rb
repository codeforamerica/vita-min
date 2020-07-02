require "rails_helper"

RSpec.feature "Viewing an anonymized intake CSV extract file" do
  let!(:intake) { create(:intake) }

  let!(:extract) { AnonymizedIntakeCsvService.new.store_csv }

  let(:auth_hash) do
    OmniAuth::AuthHash.new(
      provider: "zendesk",
      uid: "123545",
      info: {
        name: "German Geranium",
        email: "german@flowers.orange",
        role: "admin"
      },
      credentials: {
        token: "abc 123"
      }
    )
  end

  scenario "admin views recent intake csv extracts" do
    visit "/zendesk/csv-extracts"

    # redirected to sign in page
    expect(page).to have_text "Sign in with Zendesk"

    OmniAuth.config.mock_auth[:zendesk] = auth_hash
    click_link "Sign in with Zendesk"

    # shows list of all extracts
    click_link extract.upload.attachment.filename.to_s
    expect(page.response_headers).to include("Content-Type" => "text/csv")
    expect(page.response_headers["Content-Disposition"]).to include("attachment")
  end
end
