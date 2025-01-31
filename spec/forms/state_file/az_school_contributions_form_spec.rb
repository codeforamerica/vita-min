require "rails_helper"

RSpec.describe StateFile::AzSchoolContributionsForm do
  describe "#valid?" do
    let(:intake) { create :state_file_az_intake }

    context "with no radio selected" do
      let(:invalid_params) do
        {
          school_contributions: "unfilled",
        }
      end

      it "returns false" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
        expect(form.errors).to include(:school_contributions)
      end
    end

    context "with radio selected" do
      let(:params) do
        { school_contributions: "yes" }
      end

      it "returns true" do
        form = described_class.new(intake, params)
        expect(form).to be_valid
      end
    end
  end

  describe "#save" do
    let(:intake) { create :state_file_az_intake }
    let(:valid_params) do
      {
        school_contributions: "yes",
      }
    end

    it "saves the field on the intake" do
      form = described_class.new(intake, valid_params)
      expect(form).to be_valid
      form.save
      expect(intake.reload.school_contributions).to eq "yes"
    end
  end
end