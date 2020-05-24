require "rails_helper"

RSpec.feature "Viewing a document for a zendesk ticket" do
  let(:intake) { create :intake, intake_ticket_id: 123 }
  let!(:document) { create :document, :with_upload, intake: intake }
  let(:auth_hash) do
    OmniAuth::AuthHash.new(
      provider: "zendesk",
      uid: "123545",
      info: {
        name: "German Geranium",
        email: "german@flowers.orange",
      },
      credentials: {
        token: "abc 123"
      }
    )
  end
  let(:zendesk_ticket_json) do
    <<~JSON
      {"ticket": {"id": 123}}
    JSON
  end

  before do
    stub_request(:get, "https://eitc.zendesk.com/api/v2/tickets/123")
      .to_return(status: 200, body: zendesk_ticket_json, headers: { "Content-Type" => "application/json" })
  end

  scenario "displays the document after logging in" do
    visit "/zendesk/documents/#{document.id}"
    expect(page).to have_text "Sign in with Zendesk"

    OmniAuth.config.mock_auth[:zendesk] = auth_hash
    click_link "Sign in with Zendesk"

    expect(page.response_headers).to include("Content-Type" => "image/jpeg")
    expect(page.response_headers).to include("Content-Disposition" => "inline")
  end
end