require 'rails_helper'

describe Efile::Ny::It201 do
  let(:filing_status) { intake.filing_status }
  let(:intake) { create(:state_file_ny_intake) }
  let!(:dependent) { intake.dependents.create(dob: 7.years.ago) }
  let(:instance) do
    described_class.new(
      year: 2022,
      filing_status: filing_status,
      intake: intake,
      direct_file_data: intake.direct_file_data,
      dependent_count: 0
    )
  end

  describe '#calculate' do
    it "populates line info for related documents like the 213" do
      instance.calculate
      expect(instance.lines[:IT213_LINE_16].value).to eq(339)
    end
  end

  describe '#calculate_line_17' do
    it "adds up some of the prior lines" do
      expect(instance.calculate[:IT201_LINE_17]).to eq(35151)
    end
  end
end
