require "rails_helper"

describe BankAccount do
  describe "#account_type_code" do
    context "when checking" do
      let(:bank_account) { create :bank_account, account_type: "checking" }
      it "returns the enum integer value for the bank account type" do
        expect(bank_account.account_type_code).to eq 1
      end
    end

    context "when savings" do
      let(:bank_account) { create :bank_account, account_type: "savings" }
      it "returns the enum integer value for the bank account type" do
        expect(bank_account.account_type_code).to eq 2
      end
    end

    context "when nil" do
      let(:bank_account) { create :bank_account, account_type: nil }
      it "returns nil" do
        expect(bank_account.account_type_code).to eq nil
      end
    end
  end
end