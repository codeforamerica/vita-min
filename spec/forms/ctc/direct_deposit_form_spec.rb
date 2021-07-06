require "rails_helper"

describe Ctc::DirectDepositForm do
  let(:intake) { create :ctc_intake }
  let(:bank_name) { "Bank of America" }
  let(:account_type) { "checking" }
  let(:my_bank_account) { "yes" }

  let(:params) do
    {
        bank_name: bank_name,
        account_type: account_type,
        my_bank_account: my_bank_account
    }
  end
  context "validations" do
    context "bank_name" do
      context "when not present" do
        let(:bank_name) { nil }
        it "is not valid" do
          expect(described_class.new(intake, params)).not_to be_valid
        end
      end
    end

    context "bank_account_type" do
      context "when not present" do
        let(:account_type) { nil }
        it "is not valid" do
          expect(described_class.new(intake, params)).not_to be_valid
        end
      end
    end

    context "my_bank_account" do
      context "when not checked yes" do
        let(:my_bank_account) { "no" }
        it "is not valid" do
          expect(described_class.new(intake, params)).not_to be_valid
        end
      end
    end
  end

  describe '#save' do
    it 'creates a bank account object and associates it with the intake' do
      expect {
        described_class.new(intake, params).save
        intake.reload
      }.to change(BankAccount, :count).by(1)
      bank_account = BankAccount.last
      expect(bank_account.bank_name).to eq "Bank of America"
      expect(bank_account.account_type).to eq "checking"
      expect(bank_account.intake).to eq intake
    end
  end
end