require 'rails_helper'

describe Efile::Ny::NycEicRateTable do
  describe ".find_row" do
    it "returns the correct row" do
      result = described_class.find_row(2_333)
      expect(result.line_2_amt).to be_nil
      expect(result.line_5_amt).to be_nil
      expect(result.line_6_amt).to eq(0.30)

      result = described_class.find_row(15_000)
      expect(result.line_2_amt).to eq(14_999)
      expect(result.line_5_amt).to eq(0.25)
      expect(result.line_6_amt).to be_nil

      result = described_class.find_row(43_333)
      expect(result.line_2_amt).to be_nil
      expect(result.line_5_amt).to be_nil
      expect(result.line_6_amt).to eq(0.10)
    end
  end
end
