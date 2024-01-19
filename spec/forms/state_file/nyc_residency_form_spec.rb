require "rails_helper"

RSpec.describe StateFile::NycResidencyForm do
  let(:intake) { create(:state_file_ny_intake, nyc_residency: "unfilled", nyc_maintained_home: "unfilled") }

  describe "#valid?" do
    it "requires an answer for nyc_residency" do
      form = described_class.new(intake, {})
      expect(form).not_to be_valid
      expect(form.errors).to include :nyc_residency
      expect(form.errors).not_to include :nyc_maintained_home

      params = { nyc_residency: "", nyc_maintained_home: "" }
      form = described_class.new(intake, params)
      expect(form).not_to be_valid
      expect(form.errors).to include :nyc_residency
      expect(form.errors).not_to include :nyc_maintained_home
    end

    context "when nyc_residency = 'none'" do
      it "requires an answer for nyc_maintained_home" do
        params = { nyc_residency: "none" }
        form = described_class.new(intake, params)
        expect(form).not_to be_valid
        expect(form.errors).to include :nyc_maintained_home

        params = { nyc_residency: "none", nyc_maintained_home: "" }
        form = described_class.new(intake, params)
        expect(form).not_to be_valid
        expect(form.errors).to include :nyc_maintained_home
      end
    end

    context "when nyc_residency is full_year or part_year" do
      it "is valid and does not require an answer for nyc_maintained_home" do
        params = { nyc_residency: "full_year" }
        form = described_class.new(intake, params)
        expect(form).to be_valid
        expect(form.errors).not_to include :nyc_maintained_home

        params = { nyc_residency: "part_year" }
        form = described_class.new(intake, params)
        expect(form).to be_valid
        expect(form.errors).not_to include :nyc_maintained_home
      end

      it "clears any answer for nyc_maintained_home" do
        params = { nyc_residency: "full_year", nyc_maintained_home: "yes" }
        form = described_class.new(intake, params)
        expect(form).to be_valid
        expect(form.errors).not_to include :nyc_maintained_home
        expect(form.nyc_maintained_home).to eq "unfilled"
      end
    end
  end

  describe "#save" do
    it "saves the data to the intake" do
      params = { nyc_residency: "none", nyc_maintained_home: "yes" }
      form = described_class.new(intake, params)
      form.save
      intake.reload

      expect(intake.nyc_residency).to eq "none"
      expect(intake.nyc_maintained_home).to eq "yes"
    end

    context "when nyc_residency is full_year or part_year" do
      it "saves nyc_maintained_home as unfilled" do
        params = { nyc_residency: "part_year", nyc_maintained_home: "yes" }
        form = described_class.new(intake, params)
        expect(form).to be_valid # validation should clear nyc_maintained_home
        form.save
        intake.reload

        expect(intake.nyc_residency).to eq "part_year"
        expect(intake.nyc_maintained_home).to eq "unfilled"
      end
    end
  end
end
