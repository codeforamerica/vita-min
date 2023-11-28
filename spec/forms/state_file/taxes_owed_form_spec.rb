require "rails_helper"

RSpec.describe StateFile::TaxesOwedForm do
  let!(:withdraw_amount) { 912 }
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
          date_electronic_withdrawal_month: '1',
          date_electronic_withdrawal_year: '2023',
          date_electronic_withdrawal_day: '01'
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
          date_electronic_withdrawal_year: '2023',
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
end
