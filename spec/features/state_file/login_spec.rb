require "rails_helper"

RSpec.feature "Logging in with an existing account" do
  include StateFileIntakeHelper
  let(:phone_number) { "+15551231234" }
  let(:ssn) { "11223333" }
  let!(:intake) { create :state_file_az_intake, phone_number: phone_number, hashed_ssn: ssn }

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
  end

  scenario "client signs in with phone number" do
    visit "/az/login-options"
    expect(page).to have_text "Sign in to FileYourStateTaxes"
    click_on "Sign in with phone number"

    expect(page).to have_text "Sign in with your phone number"
    fill_in "Your phone number", with: phone_number
    click_on "Send code"

    perform_enqueued_jobs
    sms = FakeTwilioClient.messages.last
    code = sms.body.to_s.match(/\s(\d{6})[.]/)[1]

    fill_in "Enter the 6-digit code", with: code
    click_on "Verify code"

    expect(page).to have_text "Authentication needed to continue"
    fill_in "Enter your full Social Security Number", with: ssn
    click_on "Continue"

    expect(page).to have_text "You’re logged in!"
    click_on "Continue"

    # TODO: decide where to go
  end
end
