require "rails_helper"

RSpec.feature "Add and toggle risky domains", js: true do
  context "As an authenticated user" do
    before do
      create :safe_domain, name: "gmail.com"
      create :risky_domain, name: "fraudy.com"
      create :fraud_indicator, indicator_type: "in_riskylist", list_model_name: "Fraud::Indicators::Domain"
    end

    scenario "I can view a list of risky domains, toggle them on and off, and add another one" do
      visit hub_risky_domains_path
      expect(page).to have_content "Risky Domains List"
      within ".data-table" do
        expect(page).to have_content "fraudy.com"
      end

      within "#fraudy" do
        toggle_slider('fraud_indicators_domain_active')
      end
      expect(page).to have_content("fraudy.com toggled off.")
      expect(Fraud::Indicators::Domain.unscoped.find_by(name: "fraudy.com").activated_at).to be_nil

      within "#fraudy" do
        toggle_slider('fraud_indicators_domain_active')
      end
      expect(page).to have_content("fraudy.com toggled on.")
      expect(Fraud::Indicators::Domain.unscoped.find_by(name: "fraudy.com").activated_at).to be_present

      fill_in "Domain name", with: "def-bad.com"
      click_on "Save"

      within ".data-table" do
        expect(page).to have_content "def-bad.com"
      end

      # make sure newly added elements can be toggled on/off, too
      within "#def-bad" do
        toggle_slider('fraud_indicators_domain_active')
      end
      expect(page).to have_content("def-bad.com toggled off.")
      expect(Fraud::Indicators::Domain.unscoped.find_by(name: "def-bad.com").activated_at).to be_nil

      within "#def-bad" do
        toggle_slider('fraud_indicators_domain_active')
      end
      expect(page).to have_content("def-bad.com toggled on.")
      expect(Fraud::Indicators::Domain.unscoped.find_by(name: "def-bad.com").activated_at).to be_present
    end
  end
end