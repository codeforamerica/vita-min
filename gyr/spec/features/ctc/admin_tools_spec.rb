require "rails_helper"

RSpec.feature "Admin Tools", active_job: true do
  let(:user) { create :admin_user }

  before do
    login_as user
  end

  scenario "admin can change whether we are forwarding messages to intercom" do
    visit hub_user_profile_path
    click_on "Admin Tools"
    click_on "Intercom Message Forwarding"
    choose "Do not forward"
    click_on "Save"

    admin_toggle = AdminToggle.last
    expect(admin_toggle.name).to eq(AdminToggle::FORWARD_MESSAGES_TO_INTERCOM)
    expect(admin_toggle.value).to eq(false)
  end

  scenario "admin can click on SLA breach link" do
    visit hub_user_profile_path
    click_on "Admin Tools"
    click_on "SLA Breaches"
    expect(page).to have_text "Report run at:"
  end

  scenario "admin can click to verifications page" do
    visit hub_user_profile_path
    click_on "Admin Tools"
    click_on "Client Verification"
    expect(page).to have_text "verification attempts"
  end

  scenario "admin can click to efile errors page" do
    visit hub_user_profile_path
    click_on "Admin Tools"
    click_on "E-file Errors"
    expect(page).to have_text "Error Code"
  end

  scenario "admin can click to efile page" do
    visit hub_user_profile_path
    click_on "Admin Tools"
    click_on "E-file Dashboard"
    expect(page).to have_text "submissions"
  end
end