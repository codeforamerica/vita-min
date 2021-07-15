require 'rails_helper'

describe Ctc::FilingStatusForm do
  let(:client) { create :client, tax_returns: [(create :tax_return, filing_status: nil )]}
  let!(:intake) { create :ctc_intake, client: client }
  let(:params) { { filing_status: "single" } }

  context "validations" do
    context "when filing status is selected" do
      it "is valid" do
        expect(
          described_class.new(intake, params)
        ).to be_valid
      end
    end

    context "when filing status is not selected" do
      it "is not valid" do
        expect(
          described_class.new(intake, {})
        ).not_to be_valid
      end
    end
  end

  context "save" do
    it "persists the filing status to the client's tax return" do
      expect {
        described_class.new(intake, params).save
      }.to change(intake.client.tax_returns.first, :filing_status).from(nil).to("single")
    end
  end
end