require "rails_helper"

describe Ctc::DirectDepositForm do
  let(:intake) { create :ctc_intake }
  let(:bank_name) { "Bank of America" }
  let(:bank_account_type) { "checking" }
  let(:my_bank_account) { "yes" }

  let(:params) do
    {
        bank_name: bank_name,
        bank_account_type: bank_account_type,
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
        let(:bank_account_type) { nil }
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
    it 'persists bank name and account type to the intake' do
      expect {
        described_class.new(intake, params).save
      }.to change(intake, :bank_name).to("Bank of America")
       .and change(intake, :bank_account_type).to("checking")
    end
  end
end