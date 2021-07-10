require "rails_helper"

describe Ctc::AccountNumberForm do
  let(:intake) { create :ctc_intake, bank_account: (create :bank_account) }

  context "validations" do

    it "ensures the confirmation matches" do
      expect(
        described_class.new(intake, {
          account_number: "123456789",
          account_number_confirmation: "12345678"
        })
      ).not_to be_valid
    end

    it "is valid when the routing number is at least 9 digits and confirmation matches" do
      expect(
        described_class.new(intake, {
          account_number: "123456789",
          account_number_confirmation: "123456789"
        })
      ).to be_valid
    end
  end

  describe "#save" do
    it "saves the routing number onto an existing bank account object" do
      expect {
        described_class.new(intake, {
          account_number: "123456789",
          account_number_confirmation: "123456789"
        }).save
      }.to change(intake.bank_account, :account_number).to("123456789")
    end
  end
end