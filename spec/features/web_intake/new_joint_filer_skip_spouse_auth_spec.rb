require "rails_helper"

RSpec.feature "Web Intake Joint Filer without spouse present" do
  scenario "new client filing joint taxes with spouse and dependents" do
    # Primary Authentication
    visit "/questions/identity"
    expect(page).to have_selector("h1", text: "Sign in")
    click_on "Sign in with ID.me"

    # the ID.me flow would occur here. They should end up back on a success page.

    # Consent form
    expect(page).to have_selector("h1", text: "Great! Here's the legal stuff...")
    expect(page).to have_text("You, Gary Gnome, understand")
    check "I agree"
    click_on "Continue"

    # Marital status
    visit ever_married_questions_path
    expect(page).to have_selector("h1", text: "Have you ever been legally married?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "As of December 31, 2019, were you legally married?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "Did you live with your spouse during any part of the last six months of 2019?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "Are you legally separated?")
    click_on "No"
    expect(page).to have_selector("h1", text: "As of December 31, 2019, were you divorced?")
    click_on "No"
    expect(page).to have_selector("h1", text: "As of December 31, 2019, were you widowed?")
    click_on "No"

    # Filing status
    expect(page).to have_selector("h1", text: "Are you filing joint taxes with your spouse?")
    click_on "Yes"

    # Alimony
    expect(page).to have_selector("h1", text: "In 2019, did you or your spouse receive any income from alimony?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In 2019, did you or your spouse make any alimony payments?")
    click_on "Yes"

    # Skip Spouse Authentication
    expect(page).to have_selector("h1", text: "Spouse Identity")
    click_on "Skip this step for now"

    # Skips overview/consent and ends up at next question
    expect(page).to have_selector("h1", text: "Was your spouse a full-time student in 2019?")
  end

  context "with a valid auth token" do
    let!(:intake) { create :intake, spouse_auth_token: "t0k3n" }
    let(:spouse_auth_hash) do
      OmniAuth::AuthHash.new({
        provider: "idme",
        uid: "54321",
        info: {
          first_name: "Greta",
          last_name: "Gnome",
          name: "Greta Gnome",
          email: "greta.gardengnome@example.com",
          social: "555443333",
          phone: "15553332222",
          birth_date: "1990-09-04",
          age: 800,
          location: "Passaic Park, New Jersey",
          street: "1234 Green St",
          city: "Passaic Park",
          state: "New Jersey",
          zip: "22233",
          group: "identity",
          subgroups: ["IAL2"],
          verified: true,
        },
        credentials: {
          token: "mock_token",
          secret: "mock_secret"
        }
      })
    end

    before do
      OmniAuth.config.mock_auth[:idme] = spouse_auth_hash
    end

    scenario "spouse authenticates later" do
      visit verify_spouse_path(token: "t0k3n")
      expect(page).to have_selector("h1", text: "Verify your identity")
      # see new_joint_filers_spec for explanation of spouse authentication and mocking
      click_on "Sign in with ID.me"
      expect(page).to have_selector("h1", text: "Great! Here's the legal stuff...")
      expect(User.last.is_spouse).to eq true
      expect(page).to have_text("You, Greta Gnome, understand")
      check "I agree"
      click_on "Continue"
      expect(page).to have_selector("h1", text: "You did it!")
    end
  end
end

