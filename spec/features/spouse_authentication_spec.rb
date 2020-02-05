require "rails_helper"

RSpec.feature "Authenticate spouse for married filing jointly intakes" do
  before do
    visit "/questions/identity"
    expect(page).to have_selector("h1", text: "Sign in")
    click_on "Sign in with ID.me"
  end

  xscenario "client wants to verify spouse on same device" do
    visit "/questions/spouse-identity"
    expect(page).to have_selector("h1", text: "Spouse Identity")

    #silence_omniauth_logging do
      #OmniAuth.config.mock_auth[:idme] = :invalid_credentials
      click_on "Sign in spouse with ID.me"
    #end

    # expect primary to be signed out of ID.me (only)
    # expect spouse to register for ID.me
    # get a successful omniauth callback with spouse info
    # redirect to overview with both names
  end
end

