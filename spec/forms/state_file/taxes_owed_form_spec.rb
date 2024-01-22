require "rails_helper"

RSpec.describe StateFile::TaxesOwedForm do
  let!(:withdraw_amount) { 118 }
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
  let(:current_year) { (MultiTenantService.new(:statefile).current_tax_year + 1).to_s }

  before do
    allow(DateTime).to receive(:now).and_return DateTime.new(current_year.to_i, 1, 1)
    allow(DateTime).to receive(:current).and_return DateTime.new(current_year.to_i, 1, 1)
  end

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
      let(:valid_params) do
        {
          payment_or_deposit_type: "direct_deposit",
          routing_number: "123456789",
          routing_number_confirmation: "123456789",
          account_number: "123",
          account_number_confirmation: "123",
          account_type: "checking",
          bank_name: "Bank official",
          withdraw_amount: withdraw_amount,
          date_electronic_withdrawal_month: '4',
          date_electronic_withdrawal_year: (MultiTenantService.new(:statefile).current_tax_year + 1).to_s,
          date_electronic_withdrawal_day: '15'
        }
      end

      it "updates the intake" do
        form = described_class.new(intake, valid_params)
        expect(form).to be_valid
        form.save

        intake.reload
        expect(intake.payment_or_deposit_type).to eq "direct_deposit"
        expect(intake.account_type).to eq "checking"
        expect(intake.routing_number).to eq "123456789"
        expect(intake.account_number).to eq "123"
        expect(intake.bank_name).to eq "Bank official"
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
          bank_name: nil,
          withdraw_amount: nil,
          date_electronic_withdrawal_month: '2',
          date_electronic_withdrawal_year: current_year,
          date_electronic_withdrawal_day: '31'
        }
      end

      it "updates the intake" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid

        expect(form.errors[:routing_number_confirmation]).to be_present
        expect(form.errors[:account_number_confirmation]).to be_present
        expect(form.errors[:account_type]).to be_present
        expect(form.errors[:bank_name]).to be_present
        expect(form.errors[:withdraw_amount]).to be_present
        expect(form.errors[:date_electronic_withdrawal]).to be_present
      end
    end
  end

  describe "#valid?" do
    let(:payment_or_deposit_type) { "direct_deposit" }
    let(:routing_number) { "123456789" }
    let(:routing_number_confirmation) { "123456789" }
    let(:account_number) { "123" }
    let(:account_number_confirmation) { "123" }
    let(:account_type) { "checking" }
    let(:bank_name) { "Bank official" }
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
        bank_name: bank_name,
        withdraw_amount: withdraw_amount,
        date_electronic_withdrawal_month: month,
        date_electronic_withdrawal_year: year,
        date_electronic_withdrawal_day: day
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

      context "electronic withdrawal date is after deadline" do
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
          allow(intake).to receive(:calculated_refund_or_owed_amount).and_return(100)
        end

        it "is not valid" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors).to include :withdraw_amount
        end
      end
    end
  end
end
