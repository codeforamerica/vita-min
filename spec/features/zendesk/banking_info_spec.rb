require "rails_helper"

RSpec.feature "Viewing banking info for an intake" do
  let(:ticket_id) { 123 }
  let(:intake) do
    create(
      :intake,
      intake_ticket_id: ticket_id,
      primary_first_name: "Happy",
      primary_last_name: "Client",
      bank_name: "Self-help United",
      bank_routing_number: "12345678",
      bank_account_number: "87654321",
      bank_account_type: "checking"
    )
  end
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

  scenario "check out the bank details for an intake" do
    visit banking_info_zendesk_intake_path(intake.id)

    # redirected to sign in page
    expect(page).to have_text "Sign in with Zendesk"

    OmniAuth.config.mock_auth[:zendesk] = auth_hash
    click_link "Sign in with Zendesk"

    # redirected back to show zendesk intake banking info page
    expect(page).to have_text "German Geranium"
    expect(page).to have_text intake.bank_name
    expect(page).to have_text intake.bank_routing_number
    expect(page).to have_text intake.bank_account_number
    expect(page).to have_text intake.bank_account_type
  end
end
