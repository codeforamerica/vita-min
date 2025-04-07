require "rails_helper"

RSpec.feature "MD Taxes Owed" do
  before do
    allow(Flipper).to receive(:enabled?).and_call_original
  end

  context "before the tax deadline (extension_period flipper is off)" do
    before do
      allow(Flipper).to receive(:enabled?).with(:extension_period).and_return(false)
    end

    scenario "can select a payment date" do
      intake = create :state_file_md_intake, :taxes_owed
      login_as intake, scope: :state_file_intake

      visit "/questions/md-taxes-owed"

      expect(page).to have_text "You owe $123 in Maryland state taxes."
      click_on "Pay directly from your checking or savings account (direct debit)"

      # Check that date select is visible
      expect(page).to have_text "When would you like the funds withdrawn from your account?"
      expect(page).to have_css(".date-select")

      # Fill in bank details & select a date
      fill_in "Your total amount due is $123.", with: "100"
      select "January", from: "state_file_md_taxes_owed_form[date_electronic_withdrawal(2i)]"
      select "3", from: "state_file_md_taxes_owed_form[date_electronic_withdrawal(3i)]"
      select (Time.now.year + 1).to_s, from: "state_file_md_taxes_owed_form[date_electronic_withdrawal(1i)]"
      choose "Checking"
      fill_in "Routing Number", with: "123456789"
      fill_in "Confirm Routing Number", with: "123456789"
      fill_in "Account number", with: "987654321"
      fill_in "Confirm Account Number", with: "987654321"

      click_on "Continue"

      intake.reload
      expect(intake.direct_debit_date.strftime("%Y-%m-%d")).to eq Date.new(Time.now.year + 1, 1, 3).strftime("%Y-%m-%d")
      expect(intake.payment_or_deposit_type).to eq "direct_deposit"
    end
  end

  context "after the tax deadline (extension_period flipper is on)" do
    before do
      allow(Flipper).to receive(:enabled?).with(:extension_period).and_return(true)
    end

    scenario "cannot select a payment date and it defaults to today" do
      intake = create :state_file_md_intake, :taxes_owed
      login_as intake, scope: :state_file_intake

      visit "/questions/md-taxes-owed"

      expect(page).to have_text "You owe $123 in Maryland state taxes."
      click_on "Pay directly from your checking or savings account (direct debit)"

      # Check that date select is NOT visible and informational text IS visible
      expect(page).not_to have_text "When would you like the funds withdrawn from your account?"
      expect(page).not_to have_css(".date-select")
      expect(page).to have_text "Because you are submitting your return on or after"

      # Fill in bank details
      fill_in "Your total amount due is $123.", with: "100"
      choose "Checking"
      fill_in "Routing Number", with: "123456789"
      fill_in "Confirm Routing Number", with: "123456789"
      fill_in "Account number", with: "987654321"
      fill_in "Confirm Account Number", with: "987654321"

      click_on "Continue"

      intake.reload
      # The hidden field sets the date to Time.zone.now.to_date
      expect(intake.direct_debit_date.strftime("%Y-%m-%d")).to eq Time.zone.now.to_date.strftime("%Y-%m-%d")
      expect(intake.payment_or_deposit_type).to eq "direct_deposit"
    end
  end
end
