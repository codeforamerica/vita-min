require "rails_helper"

RSpec.describe StateFile::TaxesOwedForm do
  let(:intake) { create :state_file_id_intake }
  let(:taxes_owed) { 100 }
  let(:filing_year) { MultiTenantService.new(:statefile).current_tax_year + 1 }
  let(:tax_day) { DateTime.new(filing_year, 4, 15) }

  before do
    allow(intake).to receive(:calculated_refund_or_owed_amount).and_return(taxes_owed)
  end

  describe "when paying via mail" do
    let(:params) { { payment_or_deposit_type: "mail", app_time: DateTime.new(filing_year, 3, 15).to_s } }

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

  StateFile::StateInformationService.active_state_codes.excluding("nc", "ny").each do |state_code|
    describe "when paying via direct deposit in #{state_code}" do
      let(:intake) { create "state_file_#{state_code}_intake".to_sym }
      let(:timezone) { StateFile::StateInformationService.timezone(state_code) }
      let(:utc_offset_hours) { tax_day.in_time_zone(timezone).utc_offset / 1.hour }
      let(:tax_day_local) { tax_day - utc_offset_hours.hours } # keep the timezone in UTC, but midnight locally
      let(:app_time) { DateTime.new(filing_year, 3, 15) } # arbitrary day in the tax season
      let(:payment_deadline_date) { StateFile::StateInformationService.payment_deadline_date(state_code, app_time) }
      let(:withdrawal_month) { app_time.month }
      let(:withdrawal_day) { app_time.day }
      let(:params) {
        {
          payment_or_deposit_type: "direct_deposit",
          routing_number: "019456124",
          routing_number_confirmation: "019456124",
          account_number: "12345",
          account_number_confirmation: "12345",
          account_type: "checking",
          withdraw_amount: taxes_owed,
          date_electronic_withdrawal_month: withdrawal_month&.to_s,
          date_electronic_withdrawal_day: withdrawal_day&.to_s,
          date_electronic_withdrawal_year: app_time.year.to_s,
          app_time: app_time.to_s
        }
      }

      context "when the form is submitted before April 15th" do
        let(:app_time) { tax_day_local - 1.month }

        context "when the withdrawal date is in the future and before the payment deadline" do
          let(:withdrawal_month) { (payment_deadline_date - 1.day).month }
          let(:withdrawal_day) { (payment_deadline_date - 1.day).day }

          it "updates the intake" do
            form = described_class.new(intake, params)
            expect(form).to be_valid
            form.save

            intake.reload
            expect(intake.payment_or_deposit_type).to eq "direct_deposit"
            expect(intake.routing_number).to eq params[:routing_number]
            expect(intake.account_number).to eq params[:account_number]
            expect(intake.account_type).to eq params[:account_type]
            expect(intake.withdraw_amount).to eq params[:withdraw_amount]
            expect(intake.date_electronic_withdrawal).to eq DateTime.new(filing_year, withdrawal_month, withdrawal_day)
          end
        end

        context "when the withdrawal date is today" do
          let(:withdrawal_month) { app_time.month }
          let(:withdrawal_day) { app_time.day }

          it "updates the intake" do
            form = described_class.new(intake, params)
            expect(form).to be_valid
            form.save

            intake.reload
            expect(intake.payment_or_deposit_type).to eq "direct_deposit"
            expect(intake.routing_number).to eq params[:routing_number]
            expect(intake.account_number).to eq params[:account_number]
            expect(intake.account_type).to eq params[:account_type]
            expect(intake.withdraw_amount).to eq params[:withdraw_amount]
            expect(intake.date_electronic_withdrawal).to eq DateTime.new(filing_year, withdrawal_month, withdrawal_day)
          end
        end

        context "when it is the very last minute before April 15th, and withdrawal date is the deadline" do
          let(:app_time) { tax_day_local - 1.minute }
          let(:withdrawal_month) { payment_deadline_date.month }
          let(:withdrawal_day) { payment_deadline_date.day }

          it "it allows a valid withdrawal date" do
            form = described_class.new(intake, params)
            expect(form).to be_valid
            expect(form.errors).not_to include :date_electronic_withdrawal
          end
        end

        context "when the withdrawal date is after the payment deadline" do
          let(:withdrawal_month) { (payment_deadline_date + 1.day).month }
          let(:withdrawal_day) { (payment_deadline_date + 1.day).day }

          it "is not valid" do
            form = described_class.new(intake, params)
            expect(form).not_to be_valid
            expect(form.errors).to include :date_electronic_withdrawal
          end
        end

        context "when the withdrawal date is in the past" do
          let(:withdrawal_month) { (app_time - 1.days).month }
          let(:withdrawal_day) { (app_time - 1.days).day }

          it "is not valid" do
            form = described_class.new(intake, params)
            expect(form).not_to be_valid
            expect(form.errors).to include :date_electronic_withdrawal
            expect(form.errors.first&.type).to start_with "Please enter a date between today and on or before "
          end
        end

        context "when the withdrawal date is not a real date" do
          let(:withdrawal_month) { 2 }
          let(:withdrawal_day) { 31 }

          it "is not valid" do
            form = described_class.new(intake, params)
            expect(form).not_to be_valid
            expect(form.errors).to include :date_electronic_withdrawal
            expect(form.errors.first&.type).to eq "Please enter a valid date."
          end
        end
      end

      context "when the form is submitted on or after April 15th" do
        let(:app_time) { tax_day_local }
        let(:withdrawal_month) { nil }
        let(:withdrawal_day) { nil }
        let(:post_deadline_params) {
          params.except(
            :date_electronic_withdrawal_month,
            :date_electronic_withdrawal_day,
            :date_electronic_withdrawal_year
          )
        }

        it "defaults the withdrawal date to the current date" do
          form = described_class.new(intake, post_deadline_params)
          expect(form).to be_valid
          form.save

          intake.reload
          expect(intake.payment_or_deposit_type).to eq "direct_deposit"
          expect(intake.account_type).to eq "checking"
          expect(intake.routing_number).to eq "019456124"
          expect(intake.account_number).to eq "12345"
          expect(intake.date_electronic_withdrawal).to eq DateTime.new(filing_year, app_time.month, app_time.day).to_date
        end

        context "when there is an invalid withdrawal date" do
          let(:withdrawal_month) { (payment_deadline_date + 1.day).month }
          let(:withdrawal_day) { (payment_deadline_date + 1.day).day }

          it "it ignores the invalid withdrawal date" do
            form = described_class.new(intake, params)
            expect(form).to be_valid
          end
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
            app_time: DateTime.new(filing_year, 3, 15).to_s
          }
        end

        # ideally these should be separate tests
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
          form = described_class.new(intake, params.merge(withdraw_amount: 0))
          expect(form).not_to be_valid
          expect(form.errors).to include :withdraw_amount
          expect(form.errors.first&.type).to eq :greater_than
        end

        it "rejects withdraw amount greater than taxes owed" do
          form = described_class.new(intake, params.merge(withdraw_amount: taxes_owed + 10))
          expect(form).not_to be_valid
          expect(form.errors).to include :withdraw_amount
          expect(form.errors.first&.type).to eq "Please enter in an amount less than or equal to " + taxes_owed.to_s
        end
      end
    end
  end
end
