require "rails_helper"

RSpec.describe StateFile::NcVeteranStatusForm do
  let(:intake) { create(:state_file_nc_intake) }

  describe "#initialize" do
    it "sets attributes from params" do
      form = described_class.new(intake, { primary_veteran: "yes", spouse_veteran: "no" })
      expect(form.primary_veteran).to eq "yes"
      expect(form.spouse_veteran).to eq "no"
    end
  end

  describe "validations" do
    context "when filing status is not MFJ" do
      let(:intake) { create(:state_file_nc_intake, filing_status: "single") }

      it "validates primary_veteran" do
        form = described_class.new(intake, { primary_veteran: "", spouse_veteran: "no" })
        expect(form).not_to be_valid
        expect(form.errors[:primary_veteran]).to include "Can't be blank."
      end

      it "does not validate spouse_veteran" do
        form = described_class.new(intake, { primary_veteran: "yes", spouse_veteran: "" })
        expect(form).to be_valid
      end
    end

    context "when filing status is MFJ" do
      let(:intake) { create(:state_file_nc_intake, filing_status: "married_filing_jointly") }

      it "validates both primary_veteran and spouse_veteran" do
        form = described_class.new(intake, { primary_veteran: "", spouse_veteran: "" })
        expect(form).not_to be_valid
        expect(form.errors[:primary_veteran]).to include "Can't be blank."
        expect(form.errors[:spouse_veteran]).to include "Can't be blank."
      end
    end
  end

  describe "#save" do
    it "updates the intake with form attributes" do
      form = described_class.new(intake, { primary_veteran: "yes", spouse_veteran: "no" })
      expect(form.valid?).to be true
      form.save

      expect(intake.primary_veteran).to eq "yes"
      expect(intake.spouse_veteran).to eq "no"
    end
  end

end