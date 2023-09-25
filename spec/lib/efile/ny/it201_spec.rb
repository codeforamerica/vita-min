require 'rails_helper'

describe Efile::Ny::It201 do
  let(:filing_status) { :mfj }
  let(:instance) do
    described_class.new(
      year: 2022,
      filing_status: filing_status,
      claimed_as_dependent: false,
      dependent_count: 0,
      input_lines: {
        AMT_2: Efile::Ny::It201::ImmutableTaxFormLine.from_data_source(:AMT_2, OpenStruct.new(field1: 1234), :field1),
      },
      it213: Efile::Ny::It227.new,
      it214: Efile::Ny::It214.new,
      it215: Efile::Ny::It215.new,
      it227: Efile::Ny::It227.new
    )
  end

  describe '#calculate_line_17' do
    it "adds up some of the prior lines" do
      expect(instance.calculate[:AMT_17]).to eq(1234)
    end
  end
end
