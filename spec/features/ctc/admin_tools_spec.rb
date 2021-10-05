require "rails_helper"

RSpec.feature "Admin Tools", active_job: true do
  let(:user) { create :admin_user }

  before do
    login_as user
  end

  scenario "admin can change CTC intake capacity" do
    visit hub_user_profile_path
    click_on "Admin Tools"
    click_on "CTC Capacity"
    fill_in "Max number of completed intakes per day", with: 1
    click_on "Save"

    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
    visit "/en/questions/overview"
    click_on I18n.t('general.continue')
    expect(page).not_to have_text I18n.t("views.ctc.questions.at_capacity.title")

    create :efile_submission

    visit "/en/questions/overview"
    click_on I18n.t('general.continue')
    click_on I18n.t('general.affirmative')
    expect(page).to have_text I18n.t("views.ctc.questions.at_capacity.title")
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
end