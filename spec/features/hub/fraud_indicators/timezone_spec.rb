require "rails_helper"

RSpec.feature "Add and toggle timezones", js: true do
  let(:user) { create :admin_user }
  before do
    login_as user
  end
  context "As an authenticated user" do
    before do
      create :timezone_indicator, name: "America/Chicago", activated_at: DateTime.now
    end

    scenario "I can view a list of timezones, toggle them on and off, and add another one" do
      visit hub_timezones_path
      expect(page).to have_content "Timezones List"
      within ".data-table" do
        expect(page).to have_content "America/Chicago"
      end

      within "#america-chicago" do
        toggle_slider('fraud_indicators_timezone_active')
      end
      expect(page).to have_content("America/Chicago toggled off.")
      expect(Fraud::Indicators::Timezone.unscoped.find_by(name: "America/Chicago").activated_at).to be_nil

      within "#america-chicago" do
        toggle_slider('fraud_indicators_timezone_active')
      end
      expect(page).to have_content("America/Chicago toggled on.")
      expect(Fraud::Indicators::Timezone.unscoped.find_by(name: "America/Chicago").activated_at).to be_present

      fill_in "Timezone", with: "Russia/Moscow"
      click_on "Save"

      within ".data-table" do
        expect(page).to have_content "Russia/Moscow"
      end

      # make sure newly added elements can be toggled on/off, too
      within "#russia-moscow" do
        toggle_slider('fraud_indicators_timezone_active')
      end
      expect(page).to have_content("Russia/Moscow toggled off.")
      expect(Fraud::Indicators::Timezone.unscoped.find_by(name: "Russia/Moscow").activated_at).to be_nil

      within "#russia-moscow" do
        toggle_slider('fraud_indicators_timezone_active')
      end
      expect(page).to have_content("Russia/Moscow")
    end
  end
end