require "rails_helper"

RSpec.feature "Logging in and out to the volunteer portal" do
  before do
    # Making these users admins because we're gating the feature on that
    create(:user, name: "German Geranium", email: "german@flowers.orange")
  end

  let(:auth_hash) do
    OmniAuth::AuthHash.new(
      provider: "zendesk",
      uid: "123545",
      info: {
        name: "German Geranium",
        email: "german@flowers.orange",
        role: "admin",
      },
      credentials: {
        token: "abc 123"
      }
    )
  end

  scenario "Perform essential authenticated tasks" do
    visit user_profile_path

    # redirected to sign in page
    expect(page).to have_text "Sign in with Zendesk"

    OmniAuth.config.mock_auth[:zendesk] = auth_hash
    click_link "Sign in with Zendesk"

    expect(page).to have_text "German Geranium"
    expect(page).to have_text "Admin"

    click_on "Sign out"
    expect(page).to have_text "You've been successfully signed out."
    expect(page).to have_text "Free tax filing, real human support"
  end
end
