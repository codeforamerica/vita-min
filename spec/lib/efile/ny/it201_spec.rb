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
        AMT_2: Efile::TaxFormLine.from_data_source(:AMT_2, OpenStruct.new(field1: 1234), :field1),
      },
      it213: Efile::Ny::It213.new(
        filing_status: filing_status,
        federal_dependent_child_count: 2,
        under_4_federal_dependent_child_count: 1,
      ),
      it214: Efile::Ny::It214.new,
      it215: Efile::Ny::It215.new,
      it227: Efile::Ny::It227.new
    )
  end

  describe '#calculate' do
    it "populates line info for related documents like the 213" do
      instance.calculate
      expect(instance.lines[:IT213_AMT_16].value).to eq(0)
    end
  end

  describe '#calculate_line_17' do
    it "adds up some of the prior lines" do
      expect(instance.calculate[:AMT_17]).to eq(1234)
    end
  end
end
