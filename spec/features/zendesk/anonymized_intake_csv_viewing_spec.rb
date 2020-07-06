require "rails_helper"

RSpec.feature "Viewing an anonymized intake CSV extract file" do
  let!(:intake) { create(:intake) }
  let(:role) { "admin" }

  let!(:extract) { AnonymizedIntakeCsvService.new.store_csv }

  let(:auth_hash) do
    OmniAuth::AuthHash.new(
      provider: "zendesk",
      uid: "123545",
      info: {
        name: "German Geranium",
        email: "german@flowers.orange",
        role: role
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

    filename = extract.upload.attachment.filename.to_s
    extract_row = find("table tbody tr").text
    expect(extract_row)
      .to eq([filename, extract.record_count, extract.run_at].join(" "))

    click_on filename
    expect(page.response_headers).to include("Content-Type" => "text/csv")
    expect(page.response_headers["Content-Disposition"]).to include("attachment")
  end

  context "non-admin user" do
    let(:role) { "agent" }

    scenario "non-admin cannot view intake csv extracts" do
      visit "/zendesk/csv-extracts"

      # redirected to sign in page
      expect(page).to have_text "Sign in with Zendesk"

      OmniAuth.config.mock_auth[:zendesk] = auth_hash
      click_link "Sign in with Zendesk"

      expect(page).to have_content("You are not authorized to access that page")
    end

  end
end
