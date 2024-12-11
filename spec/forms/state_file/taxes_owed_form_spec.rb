require "rails_helper"

RSpec.describe StateFile::TaxesOwedForm do
  before do
    allow_any_instance_of(StateFile::TaxesOwedForm).to receive(:withdrawal_date_deadline)
                                                   .and_return(Date.parse("April 30th, #{current_year}"))
  end

  let!(:withdraw_amount) { 68 }
  let!(:intake) {
    create :state_file_id_intake,
           payment_or_deposit_type: "unfilled",
           withdraw_amount: withdraw_amount
  }
  let(:valid_params) do
    {
      payment_or_deposit_type: "mail"
    }
  end
  let(:current_year) { (MultiTenantService.new(:statefile).current_tax_year + 1).to_s }
  let(:pre_deadline_withdrawal_time) { DateTime.parse("April 15th, #{current_year} 11pm EST") }
  let(:post_deadline_withdrawal_time) { DateTime.parse("April 16th, #{current_year} 1am EST") }

  describe "#save" do
    context "when params valid and payment type is mail" do
      it "updates the intake" do
        form = described_class.new(intake, valid_params)
        expect(form).to be_valid
        form.save

        intake.reload
        expect(intake.payment_or_deposit_type).to eq "mail"
        expect(intake.account_type).to eq "unfilled"
      end
    end

    context "when params valid and payment type is deposit" do
      let(:bank_info_params) do
        {
          payment_or_deposit_type: "direct_deposit",
          routing_number: "019456124",
          routing_number_confirmation: "019456124",
          account_number: "12345",
          account_number_confirmation: "12345",
          account_type: "checking",
          withdraw_amount: withdraw_amount,
        }
      end

      context "before withdrawal date deadline" do
        let(:valid_params) do
          {
            date_electronic_withdrawal_month: '4',
            date_electronic_withdrawal_year: (MultiTenantService.new(:statefile).current_tax_year + 1).to_s,
            date_electronic_withdrawal_day: '15',
            app_time: pre_deadline_withdrawal_time.to_s
          }.merge(bank_info_params)
        end

        it "updates the intake" do
          form = described_class.new(intake, valid_params)
          expect(form).to be_valid
          form.save

          intake.reload
          expect(intake.payment_or_deposit_type).to eq "direct_deposit"
          expect(intake.account_type).to eq "checking"
          expect(intake.routing_number).to eq "019456124"
          expect(intake.account_number).to eq "12345"
          expect(intake.date_electronic_withdrawal).to eq Date.parse("April 15th, #{current_year}")
        end

        context "after NY's deadline and before AZ's for AZ intake" do
          let(:pre_deadline_withdrawal_time) { DateTime.parse("April 15th, #{current_year} 11:30pm MST") }
          let!(:intake) {
            create :state_file_az_intake,
                   payment_or_deposit_type: "unfilled",
                   withdraw_amount: withdraw_amount
          }

          it "updates the intake" do
            form = described_class.new(intake, valid_params)
            expect(form).to be_valid
            form.save

            intake.reload
            expect(intake.payment_or_deposit_type).to eq "direct_deposit"
            expect(intake.account_type).to eq "checking"
            expect(intake.routing_number).to eq "019456124"
            expect(intake.account_number).to eq "12345"
            expect(intake.date_electronic_withdrawal).to eq Date.parse("April 15th, #{current_year}")
        end

        context "after other states' deadline and before MD's for MD intake" do
          before do
            allow(intake).to receive(:calculated_refund_or_owed_amount).and_return(100)
          end

          let(:valid_params) do
            {
              date_electronic_withdrawal_month: '4',
              date_electronic_withdrawal_year: (MultiTenantService.new(:statefile).current_tax_year + 1).to_s,
              date_electronic_withdrawal_day: '30',
              app_time: pre_deadline_withdrawal_time.to_s
            }.merge(bank_info_params)
          end

          let!(:intake) {
            create :state_file_md_intake,
                   payment_or_deposit_type: "unfilled",
                   withdraw_amount: withdraw_amount
          }

          it "updates the intake" do
            form = described_class.new(intake, valid_params)
            expect(form).to be_valid
            form.save

            intake.reload
            expect(intake.payment_or_deposit_type).to eq "direct_deposit"
            expect(intake.account_type).to eq "checking"
            expect(intake.routing_number).to eq "019456124"
            expect(intake.account_number).to eq "12345"
            expect(intake.date_electronic_withdrawal).to eq Date.parse("April 30th, #{current_year}")
          end
        end
      end

      context "after withdrawal date deadline" do
        let(:valid_params) do
          {
            app_time: post_deadline_withdrawal_time.to_s,
            post_deadline_withdrawal_date: post_deadline_withdrawal_time.to_s
          }.merge(bank_info_params)
        end

        it "updates the intake and updates electronic withdrawal date with the current date" do
          form = described_class.new(intake, valid_params)
          expect(form).to be_valid
          form.save

          intake.reload
          expect(intake.payment_or_deposit_type).to eq "direct_deposit"
          expect(intake.account_type).to eq "checking"
          expect(intake.routing_number).to eq "019456124"
          expect(intake.account_number).to eq "12345"
          expect(intake.date_electronic_withdrawal).to eq Date.parse("April 16th, #{current_year}")
        end
      end

    end

    context "when params are not valid" do
      let(:invalid_params) do
        {
          payment_or_deposit_type: "direct_deposit",
          routing_number: "111",
          routing_number_confirmation: "123456789",
          account_number: "123",
          account_number_confirmation: "",
          account_type: nil,
          withdraw_amount: nil,
          date_electronic_withdrawal_month: '3',
          date_electronic_withdrawal_year: current_year,
          date_electronic_withdrawal_day: '31',
          app_time: pre_deadline_withdrawal_time.to_s
        }
      end

      it "returns errors" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid

        expect(form.errors[:routing_number_confirmation]).to be_present
        expect(form.errors[:account_number_confirmation]).to be_present
        expect(form.errors[:account_type]).to be_present
        expect(form.errors[:withdraw_amount]).to be_present
        expect(form.errors[:date_electronic_withdrawal]).to be_present
      end

      it "rejects withdraw amount value 0" do
        form = described_class.new(intake, invalid_params.merge(withdraw_amount: 0))
        expect(form).not_to be_valid
        expect(form.errors[:withdraw_amount]).to be_present
      end
    end
  end

  describe "#valid?" do
    let(:payment_or_deposit_type) { "direct_deposit" }
    let(:routing_number) { "019456124" }
    let(:routing_number_confirmation) { "019456124" }
    let(:account_number) { "12345" }
    let(:account_number_confirmation) { "12345" }
    let(:account_type) { "checking" }
    let(:month) { "3" }
    let(:day) { "15" }
    let(:year) { current_year }
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
        app_time: DateTime.parse("March 10th, #{current_year} 11pm EST").to_s
      }
    end

    context "when the payment_or_deposit_type is mail and no other params" do
      let(:params) { { payment_or_deposit_type: "mail" } }
      it "is valid" do
        form = described_class.new(intake, params)

        expect(form).to be_valid
      end
    end

    context "when the payment_or_deposit_type is direct_deposit" do
      context "all other params present" do
        it "is valid" do
          form = described_class.new(intake, params)
          expect(form).to be_valid
        end
      end

      context "electronic withdrawal date is not valid" do
        let(:month) { "2" }
        let(:day) { "31" }
        let(:year) { current_year }

        it "is valid" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors).to include :date_electronic_withdrawal
        end
      end

      context "electronic withdrawal date is after deadline and current time is before April 15th" do
        let(:month) { "08" }
        let(:day) { "15" }
        let(:year) { current_year }

        it "is not valid" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors).to include :date_electronic_withdrawal
        end
      end

      context "withdraw amount is higher than owed amount" do
        before do
          allow(intake).to receive(:calculated_refund_or_owed_amount).and_return(50)
        end

        it "is not valid" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors).to include :withdraw_amount
        end
      end
    end

    context "when withdrawal date is in the past" do
      let(:day) { "9" }

      it "is valid" do
        form = described_class.new(intake, params)
        expect(form).not_to be_valid
      end
    end
  end
end
