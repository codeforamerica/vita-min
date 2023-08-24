require "rails_helper"

RSpec.feature "Add and toggle routing numbers", js: true do
  let(:user) { create :admin_user}
  before do
    login_as user
  end

  context "As an authenticated user" do
    before do
      Fraud::Indicators::RoutingNumber.create(routing_number: "123456789", activated_at: DateTime.now, bank_name: "Direct Deposit Depot")
    end

    scenario "I can view a list of risky routing numbers, toggle them on and off, and add another one" do
      visit hub_routing_numbers_path
      expect(page).to have_content "Risky Routing Numbers"
      within ".data-table" do
        expect(page).to have_content "123456789"
        expect(page).to have_content "Direct Deposit Depot"
      end

      within "#id-123456789" do
        toggle_slider('fraud_indicators_routing_number_active')
      end
      expect(page).to have_content("123456789 toggled off.")
      expect(Fraud::Indicators::RoutingNumber.unscoped.find_by(routing_number: "123456789").activated_at).to be_nil

      within "#id-123456789" do
        toggle_slider('fraud_indicators_routing_number_active')
      end
      expect(page).to have_content("123456789 toggled on.")
      expect(Fraud::Indicators::RoutingNumber.unscoped.find_by(routing_number: "123456789").activated_at).to be_present

      fill_in "Routing number", with: "222222222"
      fill_in "Bank name", with: "Sketchy Bank"
      click_on "Save"

      within ".data-table" do
        expect(page).to have_content "222222222"
        expect(page).to have_content "Sketchy Bank"
      end

      # make sure newly added elements can be toggled on/off, too
      within "#id-222222222" do
        toggle_slider('fraud_indicators_routing_number_active')
      end
      expect(page).to have_content("222222222 toggled off.")
      expect(Fraud::Indicators::RoutingNumber.unscoped.find_by(routing_number: "222222222").activated_at).to be_nil

      within "#id-222222222" do
        toggle_slider('fraud_indicators_routing_number_active')
      end
      expect(page).to have_content("222222222 toggled on.")
      expect(Fraud::Indicators::RoutingNumber.unscoped.find_by(routing_number: "222222222").activated_at).to be_present
    end
  end
end