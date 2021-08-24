require "rails_helper"

describe Ctc::Filed2019Form do
  let(:client) { create :client, tax_returns: [(create :tax_return, filing_status: nil )]}
  let!(:intake) { create :ctc_intake, client: client }
  let(:params) { { filed_2019: filed_2019 } }
  let(:filed_2019) { "filed_non_filer" }
  context "validations" do
    context "when filing status is selected" do
      it "is valid" do
        expect(
          described_class.new(intake, params)
        ).to be_valid
      end
    end

    context "when filed_2019 is not selected" do
      it "is not valid" do
        expect(
          described_class.new(intake, {})
        ).not_to be_valid
      end
    end

    context "when filed_2019 is not in the set" do
      let(:filed_2019) { "on_the_moon" }
      it "is not valid" do
        expect {
          described_class.new(intake, params).save
        }.to raise_error ArgumentError
      end
    end
  end

  context "save" do
    let(:filed_2019) { "filed_non_filer" }
    it "persists the filed_2019 value to the client's tax return" do
      expect {
        described_class.new(intake, params).save
      }.to change(intake, :filed_2019).from("unfilled").to("filed_non_filer")
    end
  end
end