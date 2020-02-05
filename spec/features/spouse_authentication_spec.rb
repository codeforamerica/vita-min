require "rails_helper"

RSpec.feature "Authenticate spouse for married filing jointly intakes" do
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
    visit "/questions/identity"
    expect(page).to have_selector("h1", text: "Sign in")
    click_on "Sign in with ID.me"
    # see note below about skipping redirects
    allow_any_instance_of(Users::SessionsController).to receive(:idme_logout).and_return(
      user_idme_omniauth_callback_path(spouse: "true")
    )
    OmniAuth.config.mock_auth[:idme] = spouse_auth_hash
  end

  scenario "client wants to verify spouse on same device" do
    visit "/questions/spouse-identity"
    expect(page).to have_selector("h1", text: "Spouse Identity")

    # The following click would trigger a series of redirects
    # To simplify this feature spec, we stub out the initial request
    # in order to skip to the final redirect. We skip from step 1 to step 4.
    # Full sequences of steps
    #   1. delete destroy_idme_session_path --> redirect to external Id.me signout
    #   2. get external ID.me signout --> redirect to omniauth_failure_path(logout: "primary")
    #   3. get omniauth_failure_path(logout: "primary") --> redirect to external Id.me authorize
    #   4. get external ID.me authorize --> user_idme_omniauth_callback_path(spouse: "true")
    click_on "Sign in spouse with ID.me"
    expect(page).to have_selector("h1", text: "Welcome Gary and Greta!")
  end
end

