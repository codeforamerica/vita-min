require "rails_helper"

RSpec.feature "Logging in with an existing account" do
  include StateFileIntakeHelper
  let(:phone_number) { "+15551231234" }
  let(:email_address) { "someone@example.com" }
  let!(:az_intake) { create :state_file_az_intake, phone_number: phone_number, hashed_ssn: "111223333" }
  let!(:ny_intake) { create :state_file_ny_intake, email_address: email_address, hashed_ssn: "333221111" }

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
  end

  scenario "client signs in with phone number" do
    visit "/az/login-options"
    expect(page).to have_text "Sign in to FileYourStateTaxes"
    click_on "Sign in with phone number"

    expect(page).to have_text "Sign in with your phone number"
  end

  scenario "client signs in with email" do
    visit "/ny/login-options"
    expect(page).to have_text "Sign in to FileYourStateTaxes"
    click_on "Sign in with email"

    expect(page).to have_text "Sign in with your email address"
  end
end