require "rails_helper"

RSpec.describe StateFile::NcTaxesOwedForm do
  let!(:withdraw_amount) { 68 }
  let!(:intake) {
    create :state_file_ny_intake,
           payment_or_deposit_type: "unfilled",
           withdraw_amount: withdraw_amount
  }
  let(:valid_params) do
    {
      payment_or_deposit_type: "mail"
    }
  end
  let(:current_year) { "2024" }
  let(:pre_deadline_withdrawal_time) { DateTime.parse("April 15th, #{current_year} 11pm EST") }
  let(:post_deadline_withdrawal_time) { DateTime.parse("April 16th, #{current_year} 1am EST") }

  describe "#valid?" do
    let(:payment_or_deposit_type) { "direct_deposit" }
    let(:routing_number) { "019456124" }
    let(:routing_number_confirmation) { "019456124" }
    let(:account_number) { "12345" }
    let(:account_number_confirmation) { "12345" }
    let(:account_type) { "checking" }
    let(:month) { "3" }
    let(:day) { "" }
    let(:year) { current_year }
    let(:app_time) { DateTime.parse("March 11th, #{current_year} 4pm EDT").to_s }
    let(:params) do
      {
        payment_or_deposit_type: payment_or_deposit_type,
        routing_number: routing_number,
        routing_number_confirmation: routing_number_confirmation,
        account_number: account_number,
        account_number_confirmation: account_number_confirmation,
        account_type: account_type,
        withdraw_amount: withdraw_amount,
        date_electronic_withdrawal_month: month,
        date_electronic_withdrawal_year: year,
        date_electronic_withdrawal_day: day,
        app_time: app_time
      }
    end

    context "NC withdrawal date validations" do
      context "when the withdrawal date is in the future, on a weekday and not on a holiday" do
        let(:app_time) { DateTime.parse("March 11th, #{current_year} 4pm EDT").to_s }
        let(:day) { 13 }

        it "is valid and saves to intake" do
          form = described_class.new(intake, params)
          expect(form).to be_valid
        end
      end

      context "when withdrawal date is in the past" do
        let(:day) { "7" }
        it "is not valid" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors).to include :date_electronic_withdrawal
          expect(form.errors[:date_electronic_withdrawal]).to include I18n.t("errors.attributes.nc_withdrawal_date.past")
        end
      end

      context "when withdrawal date is on a weekend day" do
        let(:day) { "16" } # Saturday, March 16th, 2024
        it "is not valid" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors).to include :date_electronic_withdrawal
          expect(form.errors[:date_electronic_withdrawal]).to include I18n.t("errors.attributes.nc_withdrawal_date.weekend")
        end
      end

      context "when the date is a federal holiday occurring on any day except Sunday" do
        let(:app_time) { DateTime.parse("February 16th, #{current_year} 4pm EST").to_s }
        let(:month) { "2" }
        let(:day) { "19" } # Monday, Feb 19th, 2024 ~ President's day
        it "is not valid" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors).to include :date_electronic_withdrawal
          expect(form.errors[:date_electronic_withdrawal]).to include I18n.t("errors.attributes.nc_withdrawal_date.holiday")
        end
      end

      context "when it's 5pm EST and withdrawal date is less than 2 business days from today" do
        let(:app_time) { DateTime.parse("March 8th, #{current_year} 7pm EST").to_s } # Friday
        let(:day) { "11" } # Monday, March 11th, 2024
        it "is not valid" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors).to include :date_electronic_withdrawal
          expect(form.errors[:date_electronic_withdrawal]).to include I18n.t("errors.attributes.nc_withdrawal_date.post_five_pm")
        end
      end

      context "when it's 5 PM on a Sunday and the withdrawal date is more 2 days from today" do
        let(:app_time) { DateTime.parse("February 23rd, 2025 8pm EST").to_s } # Sunday
        let(:year) { "2025" }
        let(:day) { "25" }
        let(:month) { "2" }
        it "is valid" do
          form = described_class.new(intake, params)
          expect(form).to be_valid
        end
      end
    end
  end
end
