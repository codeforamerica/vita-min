require 'rails_helper'

describe Efile::Ny::It201 do
  let(:filing_status) { :mfj }
  let(:instance) do
    described_class.new(
      year: 2022,
      filing_status: filing_status,
      claimed_as_dependent: false,
      dependent_count: 0,
      lines: {
        AMT_2: 1234,
      },
      it227: Efile::Ny::It227.new
    )
  end

  describe '#calculate_line_17' do
    it "adds up some of the prior lines" do
      expect(instance.calculate[:AMT_17]).to eq(1234)
    end
  end
end