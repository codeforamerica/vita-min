require "rails_helper"

RSpec.describe StateFile::TaxesOwedForm do
  let(:intake) { create :state_file_id_intake }
  let(:taxes_owed) { 100 }
  let(:current_year) { MultiTenantService.new(:statefile).current_tax_year + 1 }
  let(:app_time) { DateTime.new(current_year, 3, 15) }

  before do
    allow(intake).to receive(:calculated_refund_or_owed_amount).and_return(taxes_owed)
  end

  describe "when paying via mail" do
    let(:params) { { payment_or_deposit_type: "mail", app_time: app_time } }

    it "updates the intake with only mail data" do
      form = described_class.new(intake, params)
      expect(form).to be_valid
      form.save

      intake.reload
      expect(intake.payment_or_deposit_type).to eq "mail"
      expect(intake.routing_number).to eq nil
      expect(intake.account_number).to eq nil
      expect(intake.account_type).to eq "unfilled"
      expect(intake.withdraw_amount).to eq nil
      expect(intake.date_electronic_withdrawal).to eq nil
    end
  end

  StateFile::StateInformationService.active_state_codes.each do |state_code|
    describe "when paying via direct deposit in #{state_code}" do
      let(:intake) { create "state_file_#{state_code}_intake".to_sym }
      let(:timezone) { StateFile::StateInformationService.timezone(state_code) }
      let(:routing_number) { "019456124" }
      let(:account_number) { "12345" }
      let(:account_type) { "checking" }
      let(:withdraw_amount) { taxes_owed }
      let(:payment_deadline_month) { StateFile::StateInformationService.payment_deadline(state_code)[:month] }
      let(:payment_deadline_day) { StateFile::StateInformationService.payment_deadline(state_code)[:day] }
      let(:withdrawal_month) { app_time.month }
      let(:params) {
        {
          payment_or_deposit_type: "direct_deposit",
          routing_number: routing_number,
          routing_number_confirmation: routing_number,
          account_number: account_number,
          account_number_confirmation: account_number,
          account_type: account_type,
          withdraw_amount: withdraw_amount,
          date_electronic_withdrawal_month: withdrawal_month&.to_s,
          date_electronic_withdrawal_day: withdrawal_day&.to_s,
          date_electronic_withdrawal_year: app_time.year.to_s,
          app_time: app_time
        }
      }

      context "when the current time is before the payment deadline" do
        let(:app_time) { DateTime.new(current_year, payment_deadline_month, payment_deadline_day - 5) }

        context "when the withdrawal date is after the current time and before the payment deadline" do
          let(:withdrawal_month) { (app_time + 1.day).month }
          let(:withdrawal_day) { (app_time + 1.day).day }

          it "updates the intake" do
            form = described_class.new(intake, params)
            expect(form).to be_valid
            form.save

            intake.reload
            expect(intake.payment_or_deposit_type).to eq "direct_deposit"
            expect(intake.routing_number).to eq routing_number
            expect(intake.account_number).to eq account_number
            expect(intake.account_type).to eq account_type
            expect(intake.withdraw_amount).to eq withdraw_amount
            expect(intake.date_electronic_withdrawal).to eq DateTime.new(current_year, withdrawal_month, withdrawal_day)
          end
        end

        context "when the withdrawal date is after the payment deadline" do
          let(:withdrawal_month) { payment_deadline_month + 1 }
          let(:withdrawal_day) { payment_deadline_day }

          it "is not valid" do
            form = described_class.new(intake, params)
            expect(form).not_to be_valid
            expect(form.errors).to include :date_electronic_withdrawal
          end
        end

        context "when withdrawal date is before the current time" do
          let(:withdrawal_month) { (app_time - 2.days).month }
          let(:withdrawal_day) { (app_time - 2.days).day }

          it "is not valid" do
            form = described_class.new(intake, params)
            expect(form).not_to be_valid
            expect(form.errors).to include :date_electronic_withdrawal
          end
        end

        context "when the withdrawal date is not a real date" do
          let(:withdrawal_month) { 2 }
          let(:withdrawal_day) { 31 }

          it "is not valid" do
            form = described_class.new(intake, params)
            expect(form).not_to be_valid
            expect(form.errors).to include :date_electronic_withdrawal
          end
        end
      end

      context "when the current time is on or after the payment deadline" do
        let(:app_time) { DateTime.new(current_year, payment_deadline_month + 1, payment_deadline_day).in_time_zone(timezone) }
        let(:withdrawal_month) { nil }
        let(:withdrawal_day) { nil }
        let(:post_deadline_params) {
          params.except(
            :date_electronic_withdrawal_month,
            :date_electronic_withdrawal_day,
            :date_electronic_withdrawal_year
          )
        }

        it "sets the withdrawal date to the current date" do
          form = described_class.new(intake, post_deadline_params)
          expect(form).to be_valid
          form.save

          intake.reload
          expect(intake.payment_or_deposit_type).to eq "direct_deposit"
          expect(intake.account_type).to eq "checking"
          expect(intake.routing_number).to eq "019456124"
          expect(intake.account_number).to eq "12345"
          expect(intake.date_electronic_withdrawal).to eq DateTime.new(current_year, app_time.month, app_time.day)
        end

      end

      context "when banking info params are not valid" do
        let(:invalid_params) do
          {
            payment_or_deposit_type: "direct_deposit",
            routing_number: "111",
            routing_number_confirmation: "123456789",
            account_number: "123",
            account_number_confirmation: "",
            account_type: nil,
            withdraw_amount: nil,
            app_time: app_time
          }
        end

        it "returns errors" do
          form = described_class.new(intake, invalid_params)
          expect(form).not_to be_valid
          expect(form.errors).to include :routing_number_confirmation
          expect(form.errors).to include :account_number_confirmation
          expect(form.errors).to include :account_type
          expect(form.errors).to include :withdraw_amount
          expect(form.errors).to include :date_electronic_withdrawal
        end

        it "rejects withdraw amount value 0" do
          form = described_class.new(intake, invalid_params.merge(withdraw_amount: 0))
          expect(form).not_to be_valid
          expect(form.errors).to include :withdraw_amount
        end

        it "rejects withdraw amount greater than taxes owed" do
          form = described_class.new(intake, invalid_params.merge(withdraw_amount: taxes_owed + 10))
          expect(form).not_to be_valid
          expect(form.errors).to include :withdraw_amount
        end
      end
    end
  end
end
