require "rails_helper"

RSpec.describe StateFile::NcTaxesOwedForm do
  let(:intake) { create :state_file_nc_intake }
  let(:timezone) { StateFile::StateInformationService.timezone(intake.state_code) }
  let(:current_year) { 2024 } # using weekend & holiday dates from 2024
  let(:app_time) { DateTime.new(current_year, 3, 5) }
  let(:withdrawal_month) { app_time.month }
  let(:withdrawal_day) { app_time.day }
  let(:params) {
    {
      payment_or_deposit_type: "direct_deposit",
      routing_number: "019456124",
      routing_number_confirmation: "019456124",
      account_number: "12345",
      account_number_confirmation: "12345",
      account_type: "savings",
      withdraw_amount: 100,
      date_electronic_withdrawal_month: withdrawal_month.to_s,
      date_electronic_withdrawal_day: withdrawal_day.to_s,
      date_electronic_withdrawal_year: app_time.year.to_s,
      app_time: app_time.to_s
    }
  }

  describe "when paying via direct deposit and scheduling a payment in NC" do

    context "when the withdrawal date is one day in the future, on a weekday, not on a holiday, and filing before 5pm" do
      let(:withdrawal_month) { app_time.month }
      let(:withdrawal_day) { app_time.day + 1 }
      let(:app_time) { DateTime.new(current_year, 3, 5, 12, 0, 0) }

      it "is valid and saves the intake" do
        form = described_class.new(intake, params)
        expect(form).to be_valid
      end
    end

    context "when the withdrawal date is in the past" do
      let(:withdrawal_month) { app_time.month }
      let(:withdrawal_day) { app_time.day - 1 }

      it "is not valid" do
        form = described_class.new(intake, params)
        expect(form).not_to be_valid
        expect(form.errors).to include :date_electronic_withdrawal
        expect(form.errors[:date_electronic_withdrawal]).to include I18n.t("errors.attributes.nc_withdrawal_date.past")
      end
    end

    context "when the withdrawal date is today" do
      let(:withdrawal_month) { app_time.in_time_zone(timezone).month }
      let(:withdrawal_day) { app_time.in_time_zone(timezone).day }

      it "is not valid" do
        form = described_class.new(intake, params)
        expect(form).not_to be_valid
        expect(form.errors).to include :date_electronic_withdrawal
        expect(form.errors[:date_electronic_withdrawal]).to include I18n.t("errors.attributes.nc_withdrawal_date.past")
      end
    end

    context "when withdrawal date is on a weekend day" do
      let(:withdrawal_month) { 3 }
      let(:withdrawal_day) { 16 } # Saturday, March 16th, 2024

      it "is not valid" do
        form = described_class.new(intake, params)
        expect(form).not_to be_valid
        expect(form.errors).to include :date_electronic_withdrawal
        expect(form.errors[:date_electronic_withdrawal]).to include I18n.t("errors.attributes.nc_withdrawal_date.weekend")
      end
    end

    context "when the date is a federal holiday and not on Sunday" do
      let(:app_time) { DateTime.new(current_year, 2, 16).in_time_zone(timezone) }
      let(:withdrawal_month) { 2 }
      let(:withdrawal_day) { 19 } # Monday, Feb 19th, 2024 ~ President's day

      it "is not valid" do
        form = described_class.new(intake, params)
        expect(form).not_to be_valid
        expect(form.errors).to include :date_electronic_withdrawal
        expect(form.errors[:date_electronic_withdrawal]).to include I18n.t("errors.attributes.nc_withdrawal_date.holiday")
      end
    end

    context "when it's 5pm EST and withdrawal date is less than 2 business days from today" do
      let(:app_time) { DateTime.new(current_year, 3, 15, 21, 0, 0) } # UTC offset = -4; March 15th is DST
      let(:withdrawal_month) { 3 }
      let(:withdrawal_day) { 18 } # the following Monday

      it "is not valid" do
        form = described_class.new(intake, params)
        expect(form).not_to be_valid
        expect(form.errors).to include :date_electronic_withdrawal
        expect(form.errors[:date_electronic_withdrawal]).to include I18n.t("errors.attributes.nc_withdrawal_date.post_five_pm")
      end
    end

    context "when it's 4:59pm EST and withdrawal date is less than 2 business days from today" do
      let(:app_time) { DateTime.new(current_year, 3, 15, 20, 59, 0) } # UTC offset = -4; March 15th is DST
      let(:withdrawal_month) { 3 }
      let(:withdrawal_day) { 18 } # the following Monday

      it "is valid" do
        form = described_class.new(intake, params)
        expect(form).to be_valid
      end
    end

    context "when it's 5 PM on a Sunday and the withdrawal date is more 2 days from today" do
      let(:app_time) { DateTime.new(current_year, 2, 25, 17, 0, 0).in_time_zone(timezone) } # Sunday
      let(:withdrawal_month) { 2 }
      let(:withdrawal_day) { 27 }

      it "is valid" do
        form = described_class.new(intake, params)
        expect(form).to be_valid
      end
    end
  end
end
