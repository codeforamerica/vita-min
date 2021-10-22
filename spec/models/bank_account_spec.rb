# == Schema Information
#
# Table name: bank_accounts
#
#  id                          :bigint           not null, primary key
#  account_type                :integer
#  encrypted_account_number    :string
#  encrypted_account_number_iv :string
#  encrypted_bank_name         :string
#  encrypted_bank_name_iv      :string
#  encrypted_routing_number    :string
#  encrypted_routing_number_iv :string
#  hashed_account_number       :string
#  hashed_routing_number       :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  intake_id                   :bigint
#
# Indexes
#
#  index_bank_accounts_on_intake_id  (intake_id)
#
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

  describe "before_save" do
    before do
      allow(Rails.configuration).to receive(:secret_key_base).and_return "secret"
    end

    context "when routing number changes" do
      let(:bank_account) { create :bank_account, routing_number: "123456789" }

      it "sets hashed_routing_number" do
        expect {
          bank_account.update(routing_number: "123456781")
        }.to change(bank_account, :hashed_routing_number)
                 .from("e9f1f91535398c73105b095ee2be45fa6a26fd4ee56f17b1410ce2145850df42")
                 .to("b75a018e543d5731dd793285fdec672ae17f89b1199823250617c6cb90f75d71")
      end
    end

    context "when routing number does not change" do
      let(:bank_account) { create :bank_account }

      it "does not change the hashed_routing_number" do
        expect {
          bank_account.update(bank_name: "New Bank name")
        }.not_to change(bank_account, :hashed_routing_number)
      end
    end

    context "when bank account number changes" do
      let(:bank_account) { create :bank_account, account_number: "1230000123" }
      it "changes the hashed_account_number" do
        expect {
          bank_account.update(account_number: "12300001233")
        }.to change(bank_account, :hashed_account_number)
                 .from("6ef948a9e08a7ac6be4ada6431cd827bc803abaf5fd14c1f69d97ea00e0b8ee3")
                 .to("89cdb4831d672d5d33778369a21cef2bc54ab89d4ed6ea333698cf1e02f25e9d")
      end
    end
  end
end
