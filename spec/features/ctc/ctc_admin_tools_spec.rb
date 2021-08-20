require "rails_helper"

RSpec.feature "CTC Admin Tools", active_job: true do
  let(:user) { create :admin_user }

  before do
    login_as user
  end

  xscenario "admin can change CTC intake capacity" do
    visit hub_user_profile_path
    click_on "CTC Admin Tools"
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
end