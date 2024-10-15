require 'rails_helper'

describe Efile::Id::Id40Calculator do
  let(:intake) { create(:state_file_id_intake) }
  let(:instance) do
    described_class.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end

  describe "Line 6a: Primary Taxpayer Exemption" do
    context "when taxpayer is not claimed as dependent" do
      it "returns 1" do
        allow(intake.direct_file_data).to receive(:claimed_as_dependent?).and_return(false)
        instance.calculate
        expect(instance.lines[:ID40_LINE_6A].value).to eq(1)
      end
    end

    context "when taxpayer is claimed as dependent" do
      it "returns 0" do
        allow(intake.direct_file_data).to receive(:claimed_as_dependent?).and_return(true)
        instance.calculate
        expect(instance.lines[:ID40_LINE_6A].value).to eq(0)
      end
    end
  end

  describe "Line 6b: Spouse Exemption" do
    context "when filing jointly and spouse is not a dependent" do
      it "returns 1" do
        allow(intake).to receive(:filing_status_mfj?).and_return(true)
        allow(intake.direct_file_data).to receive(:spouse_is_a_dependent?).and_return(false)
        instance.calculate
        expect(instance.lines[:ID40_LINE_6B].value).to eq(1)
      end
    end

    context "when not filing jointly or spouse is a dependent" do
      it "returns 0" do
        allow(intake).to receive(:filing_status_mfj?).and_return(false)
        instance.calculate
        expect(instance.lines[:ID40_LINE_6B].value).to eq(0)
      end
    end
  end

  describe "Line 6c: Dependents" do
    before do
      3.times { intake.dependents.create! }
    end
    it "returns the number of dependents" do
      instance.calculate
      expect(instance.lines[:ID40_LINE_6C].value).to eq(3)
    end
  end

  describe "Line 6d: Total Exemptions" do
    it "sums lines 6a, 6b, and 6c" do
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_6A).and_return(1)
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_6B).and_return(1)
      allow(instance).to receive(:line_or_zero).with(:ID40_LINE_6C).and_return(2)

      instance.calculate
      expect(instance.lines[:ID40_LINE_6D].value).to eq(4)
    end
  end
end