require "rails_helper"

RSpec.feature "Viewing a document for a zendesk ticket" do
  let(:ticket_id) { 123 }
  let(:intake) do
    create(
      :intake, :with_banking_details,
      intake_ticket_id: ticket_id,
      primary_first_name: "German",
      primary_last_name: "Geranium"
    )
  end
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
      {"ticket": {"id": 123, "subject": "German Geranium"}}
    JSON
  end

  before do
    stub_request(:get, "https://eitc.zendesk.com/api/v2/tickets/123")
      .to_return(status: 200, body: zendesk_ticket_json, headers: { "Content-Type" => "application/json" })
  end

  scenario "check out the documents for a zendesk ticket" do
    visit "/zendesk/tickets/#{ticket_id}"

    # redirected to sign in page
    expect(page).to have_text "Sign in with Zendesk"

    OmniAuth.config.mock_auth[:zendesk] = auth_hash
    click_link "Sign in with Zendesk"

    # redirected back to show zendesk ticket page
    expect(page).to have_text "German Geranium"

    click_link "Bank Info"
    expect(current_path).to eq(banking_info_zendesk_intake_path(:id => intake.id))

    visit "/zendesk/tickets/#{ticket_id}"

    click_link "13614c_GermanGeranium.pdf"
    expect(page.response_headers).to include("Content-Type" => "application/pdf")
    expect(page.response_headers).to include("Content-Disposition" => "inline")
    visit "/zendesk/tickets/#{ticket_id}"

    click_link "Consent_GermanGeranium.pdf"
    expect(page.response_headers).to include("Content-Type" => "application/pdf")
    expect(page.response_headers).to include("Content-Disposition" => "inline")
    visit "/zendesk/tickets/#{ticket_id}"

    click_link "picture_id.jpg"
    expect(page.response_headers).to include("Content-Type" => "image/jpeg")
    expect(page.response_headers).to include("Content-Disposition" => "inline")
  end
end
