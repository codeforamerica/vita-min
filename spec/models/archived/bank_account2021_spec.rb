# == Schema Information
#
# Table name: archived_bank_accounts_2021
#
#  id                          :bigint           not null, primary key
#  account_number              :text
#  account_type                :integer
#  bank_name                   :string
#  encrypted_account_number    :string
#  encrypted_account_number_iv :string
#  encrypted_bank_name         :string
#  encrypted_bank_name_iv      :string
#  encrypted_routing_number    :string
#  encrypted_routing_number_iv :string
#  hashed_account_number       :string
#  hashed_routing_number       :string
#  routing_number              :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  archived_intakes_2021_id    :bigint
#
# Indexes
#
#  index_archived_bank_accounts_2021_on_archived_intakes_2021_id  (archived_intakes_2021_id)
#  index_archived_bank_accounts_2021_on_hashed_account_number     (hashed_account_number)
#  index_archived_bank_accounts_2021_on_hashed_routing_number     (hashed_routing_number)
#
# Foreign Keys
#
#  fk_rails_...  (archived_intakes_2021_id => archived_intakes_2021.id)
#
require "rails_helper"

describe Archived::BankAccount2021 do
  context "encrypted attrs" do
    describe "#bank_name" do
      let(:to_bank_name) { create :archived_2021_bank_account, bank_name: "Bank of Two Melons", intake: (create :archived_2021_ctc_intake) }
      let(:to_encrypted_bank_name) { create :archived_2021_bank_account, attr_encrypted_bank_name: "Bank of Three Melons", bank_name: nil, intake: (create :archived_2021_ctc_intake) }

      it "is not encrypted" do
        expect(to_bank_name.encrypted_attribute?(:bank_name)).to be_falsey
      end

      it "reads from the new attribute (if it is present) OR the old encrypted attribute" do
        expect(to_bank_name.read_attribute(:bank_name)).to eq "Bank of Two Melons"
        expect(to_encrypted_bank_name.read_attribute(:bank_name)).to eq nil
        expect(to_encrypted_bank_name.bank_name).to eq "Bank of Three Melons"
        expect(to_bank_name.bank_name).to eq "Bank of Two Melons"
      end
    end

    describe "#routing_number" do
      let(:to_routing_number) { create :archived_2021_bank_account, routing_number: "124578965", intake: (create :archived_2021_ctc_intake) }
      let(:to_encrypted_routing_number) { create :archived_2021_bank_account, attr_encrypted_routing_number: "123456789", routing_number: nil, intake: (create :archived_2021_ctc_intake) }

      it "is not encrypted" do
        expect(to_routing_number.encrypted_attribute?(:routing_number)).to be_falsey
      end

      it "reads from the new attribute OR the old encrypted attribute" do
        expect(to_routing_number.read_attribute(:routing_number)).to eq "124578965"
        expect(to_encrypted_routing_number.read_attribute(:routing_number)).to eq nil
        expect(to_encrypted_routing_number.routing_number).to eq "123456789"
        expect(to_routing_number.routing_number).to eq "124578965"
      end
    end

    describe "#account_number" do
      let(:to_account_number) { create :archived_2021_bank_account, account_number: "1234567879", intake: (create :archived_2021_ctc_intake) }
      let(:to_encrypted_account_number) { create :archived_2021_bank_account, attr_encrypted_account_number: "1234567879", account_number: nil, intake: (create :archived_2021_ctc_intake) }

      it "is encrypted" do
        expect(to_account_number.encrypted_attribute?(:account_number)).to be_truthy
      end

      it "reads from the new attribute OR the old encrypted attribute" do
        expect(to_account_number.read_attribute(:account_number)).to eq "1234567879"
        expect(to_encrypted_account_number.read_attribute(:account_number)).to eq nil
        expect(to_encrypted_account_number.account_number).to eq "1234567879"
        expect(to_account_number.account_number).to eq "1234567879"
      end
    end
  end
end
