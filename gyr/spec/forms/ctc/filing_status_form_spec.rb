require 'rails_helper'

describe Ctc::FilingStatusForm do
  let(:client) { create :client, tax_returns: [(build :ctc_tax_return, filing_status: nil)] }
  let!(:intake) { create :ctc_intake, client: client }


  context "validations" do
    context "when filing status is selected" do
      it "is valid" do
        expect(
          described_class.new(intake, { filing_status: "single" })
        ).to be_valid
      end
    end

    context "when filing status is not selected" do
      it "is not valid" do
        expect(
          described_class.new(intake, { filing_status: nil })
        ).not_to be_valid
      end
    end
  end

  context "save" do
    it "persists the filing status to the client's tax return" do
      expect(intake.client.tax_returns.first.filing_status).to eq nil
      described_class.new(intake, { filing_status: "single" }).save
      expect(intake.client.tax_returns.first.filing_status).to eq "single"
    end
  end
end