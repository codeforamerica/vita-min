# == Schema Information
#
# Table name: bank_accounts
#
#  id                          :bigint           not null, primary key
#  account_number              :text
#  account_type                :integer
#  bank_name                   :string
#  encrypted_account_number    :string
#  encrypted_account_number_iv :string
#  encrypted_bank_name         :string
#  encrypted_bank_name_iv      :string
#  hashed_account_number       :string
#  routing_number              :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  intake_id                   :bigint
#
# Indexes
#
#  index_bank_accounts_on_hashed_account_number  (hashed_account_number)
#  index_bank_accounts_on_intake_id              (intake_id)
#  index_bank_accounts_on_routing_number         (routing_number)
#
# Foreign Keys
#
#  fk_rails_...  (intake_id => intakes.id)
#
require "rails_helper"

describe BankAccount do

  describe "#account_number" do
    let(:bank_account) { create :bank_account, attr_encrypted_account_number: "12345678910", account_number: nil }
    it "can read account_number when there is only an old encrypted value" do
      expect(bank_account.read_attribute(:account_number)).to eq nil
      expect(bank_account.account_number).to eq "12345678910"
    end

    it "can write account_number to the new encrypted field" do
      bank_account.update(account_number: "123456789101")
      expect(bank_account.attr_encrypted_account_number).to eq "12345678910"
      expect(bank_account.account_number).to eq "123456789101"
    end
  end

  describe "#bank_name" do
    let(:bank_account) { create :bank_account, attr_encrypted_bank_name: "Some bank", bank_name: nil }
    it "can read account_number from encrypted field only" do
      expect(bank_account.bank_name).to eq "Some bank"
    end

    it "can write bank_name to the new unencrypted field" do
      bank_account.update(bank_name: "Any bank")
      expect(bank_account.read_attribute(:bank_name)).to eq "Any bank"
      expect(bank_account.bank_name).to eq "Any bank"
    end
  end

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

  describe "#duplicates" do
    context "when there is a bank account with duplicated routing and account number" do
      let(:bank_account) { create :bank_account }

      before do
        create :bank_account
      end

      it "returns a collection of duplicates" do
        expect(bank_account.duplicates.length).to eq 1
        expect(bank_account.duplicates).to include(an_instance_of(BankAccount))
      end
    end

    context "when there is a bank account with same account number but different routing number" do
      let(:bank_account) { create :bank_account }

      before do
        create :bank_account, routing_number: "111111111"
      end

      it "is empty" do
        expect(bank_account.duplicates.length).to eq 0
      end
    end
  end
  
  describe "before_save" do
    context "when bank account number changes" do
      let(:bank_account) { create :bank_account, account_number: "1230000123" }
      it "changes the hashed_account_number" do
        expect {
          bank_account.update(account_number: "12300001233")
        }.to change(bank_account, :hashed_account_number)
      end
    end

    context "when bank account number does not change" do
      let(:bank_account) { create :bank_account, account_number: "1230000123" }
      before do
        allow(DeduplificationService).to receive(:sensitive_attribute_hashed).and_call_original
      end
      it "does not change the hashed_account_number" do
        expect {
          bank_account.update(account_number: "1230000123")
        }.not_to change(bank_account, :hashed_account_number)
      end
    end
  end
end
