require 'rails_helper'

describe Efile::Ny::It201 do
  let(:filing_status) { intake.filing_status }
  let(:intake) { create(:state_file_ny_intake) }
  let!(:dependent) { intake.dependents.create(dob: 7.years.ago) }
  let(:eligibility_lived_in_state) { true }
  let(:instance) do
    described_class.new(
      year: MultiTenantService.statefile.current_tax_year,
      filing_status: filing_status,
      intake: intake,
      direct_file_data: intake.direct_file_data,
      eligibility_lived_in_state: eligibility_lived_in_state,
      dependent_count: 0
    )
  end

  describe '#calculate_line_17' do
    it "adds up some of the prior lines" do
      expect(instance.calculate[:IT201_LINE_17]).to eq(35151)
    end
  end

  # TODO: flesh out this test suite on the IT213 calculations
  describe '#calculate_it213' do
    context "when the client is not eligible because they didn't live in NY state all year" do
      let(:eligibility_lived_in_state) { false }

      it "stops calculating IT213 after line 1 and sets IT213_LINE_14 to 0" do
        instance.calculate
        expect(instance.lines[:IT213_LINE_1].value).to be_falsey
        expect(instance.lines[:IT213_LINE_2]).to be_nil
        expect(instance.lines[:IT213_LINE_14].value).to eq(0)
      end
    end

    context "when the client is not eligible because they didn't claim federal CTC or have low enough AGI" do
      before do
        intake.direct_file_data.fed_wages = 200000
        intake.direct_file_data.fed_ctc = 0
      end

      it "stops calculating after line 3 and sets IT213_LINE_14 to 0" do
        instance.calculate
        expect(instance.lines[:IT213_LINE_1].value).to be_truthy
        expect(instance.lines[:IT213_LINE_2].value).to be_falsey
        expect(instance.lines[:IT213_LINE_3].value).to be_falsey
        expect(instance.lines[:IT213_LINE_4]).to be_nil
        expect(instance.lines[:IT213_LINE_14].value).to eq(0)
      end
    end

    context "when the client is eligible and has an IT213 credit" do
      it "populates line info for related documents like the 213" do
        instance.calculate
        expect(instance.lines[:IT213_LINE_14].value).to eq(330)
      end
    end
  end
end
