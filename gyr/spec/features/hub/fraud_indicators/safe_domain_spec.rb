require "rails_helper"

RSpec.feature "Add and toggle risky domains", js: true do
  let(:user) { create :admin_user}
  before do
    login_as user
  end

  context "As an authenticated user" do
    before do
      create :safe_domain, name: "example.com"
      create :risky_domain, name: "fraudy.com"
      create :fraud_indicator, indicator_type: "not_in_safelist", list_model_name: "Fraud::Indicators::Domain"
    end

    scenario "I can view a list of risky domains, toggle them on and off, and add another one" do
      visit hub_safe_domains_path
      expect(page).to have_content "Safe Domains List"
      within ".data-table" do
        expect(page).to have_content "example.com"
      end

      within "#example" do
        toggle_slider('fraud_indicators_domain_active')
      end
      expect(page).to have_content("example.com toggled off.")
      expect(Fraud::Indicators::Domain.unscoped.find_by(name: "example.com").activated_at).to be_nil

      within "#example" do
        toggle_slider('fraud_indicators_domain_active')
      end
      expect(page).to have_content("example.com toggled on.")
      expect(Fraud::Indicators::Domain.unscoped.find_by(name: "example.com").activated_at).to be_present

      fill_in "Domain name", with: "def-ok.com"
      click_on "Save"

      within ".data-table" do
        expect(page).to have_content "def-ok.com"
      end

      # make sure newly added elements can be toggled on/off, too
      within "#def-ok" do
        toggle_slider('fraud_indicators_domain_active')
      end
      expect(page).to have_content("def-ok.com toggled off.")
      expect(Fraud::Indicators::Domain.unscoped.find_by(safe: true, name: "def-ok.com").activated_at).to be_nil

      within "#def-ok" do
        toggle_slider('fraud_indicators_domain_active')
      end
      expect(page).to have_content("def-ok.com toggled on.")
      expect(Fraud::Indicators::Domain.unscoped.find_by(safe: true, name: "def-ok.com").activated_at).to be_present
    end
  end
end