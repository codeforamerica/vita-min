require "rails_helper"

RSpec.feature "Visit CTC home page" do
  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  it "has content" do
    visit "/"
    expect(page).to have_text I18n.t("views.ctc_pages.home.header")
    expect(page).to have_text I18n.t("views.ctc_pages.home.obtain.full_return.gyr_diy_link")
  end

  context "when the DIY link is disabled" do
    before do
      ENV['CTC_HIDE_DIY_LINK'] = 'true'
    end

    after do
      ENV.delete('CTC_HIDE_DIY_LINK')
    end

    it "doesn't show the DIY link" do
      visit "/"
      expect(page).to have_text I18n.t("views.ctc_pages.home.header")
      expect(page).not_to have_text I18n.t("views.ctc_pages.home.obtain.full_return.gyr_diy_link")
    end
  end

  context "when someone signs up for updates for IRS portal opening" do
    it "saves their contact information" do
      visit "/"
      expect(page).to have_text I18n.t("views.ctc_pages.home.sign_up_for_reminders.body")
      click_on I18n.t("views.ctc_pages.home.sign_up_for_reminders.button")

      expect(page).to have_text I18n.t("views.ctc_pages.signups.new.header")
      fill_in I18n.t("general.name"), with: "Interested Person"
      fill_in I18n.t("general.email_address"), with: "remindme@example.com"
      fill_in I18n.t("general.phone_number"), with: "4153334444"
      click_on I18n.t('views.ctc_pages.signups.new.submit')

      sign_up_attributes = CtcSignup.last.attributes
      expect(sign_up_attributes).to include('name' => "Interested Person")
      expect(sign_up_attributes).to include('email_address' => 'remindme@example.com')
      expect(sign_up_attributes).to include('phone_number' => '+14153334444')

      expect(page).to have_text I18n.t("views.ctc_pages.signups.confirmation.header")
      expect(page).to have_text I18n.t("views.ctc_pages.signups.confirmation.body")
      click_on I18n.t('views.ctc_pages.signups.confirmation.button')
      expect(page).to have_text I18n.t('views.ctc_pages.home.header')
    end
  end
end
