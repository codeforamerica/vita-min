require "rails_helper"

RSpec.describe StateFile::AzCharitableContributionsForm do
  describe "#valid?" do
    let(:intake) { create :state_file_az_intake }

    context "with no radio selected" do
      let(:invalid_params) do
        {
          charitable_contributions: "unfilled",
        }
      end

      it "returns false" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
        expect(form.errors).to include(:charitable_contributions)
      end
    end

    context "when non cash contributions exceed 500" do
      let(:invalid_params) do
        {
          charitable_contributions: "yes",
          charitable_cash: 100,
          charitable_noncash: 600,
        }
      end

      it "returns false" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
      end
    end
  end



  describe "#save" do
    let(:intake) { create :state_file_az_intake }
    let(:valid_params) do
      {
        charitable_contributions: "yes",
        charitable_cash: 100,
        charitable_noncash: 100,
      }
    end

    it "saves the charitable contributions amount to the intake" do
      form = described_class.new(intake, valid_params)
      expect(form).to be_valid
      form.save
      expect(intake.reload.charitable_cash).to eq 100
      expect(intake.reload.charitable_noncash).to eq 100
    end
  end

  describe "no charitable contributions to save" do
    let(:intake) { create :state_file_az_intake }
    let(:valid_params) do
      {
        charitable_contributions: "no",
        charitable_cash: "",
        charitable_noncash: "",
      }
    end

    it "proceeds with nil for cash and non-cash contributions" do
      form = described_class.new(intake, valid_params)
      expect(form).to be_valid
      form.save
      expect(intake.reload.charitable_cash).to be_nil
      expect(intake.reload.charitable_noncash).to be_nil
    end
  end

  describe "going back and saying no to charitable contributions" do
    let(:intake) { create :state_file_az_intake, charitable_cash: 100, charitable_noncash: 100}
    let(:valid_params) do
      {
        charitable_contributions: "no",
        charitable_cash: 100,
        charitable_noncash: 100,
      }
    end

    it "proceeds with nil amounts for cash and noncash contributions" do
      form = described_class.new(intake, valid_params)
      expect(form).to be_valid
      form.save
      expect(intake.reload.charitable_cash).to be_nil
      expect(intake.reload.charitable_noncash).to be_nil
    end
  end
end



