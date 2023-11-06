require "rails_helper"

RSpec.describe StateFile::AzCharitableContributionsForm do
  describe "#valid?" do
    let(:intake) { create :state_file_az_intake }

    context "with empty last names" do
      let(:invalid_params) do
        {
          has_prior_last_names: "yes",
          prior_last_names: ""
        }
      end

      it "returns false" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
      end
    end

    context "with no radio selected" do
      let(:invalid_params) do
        {
          has_prior_last_names: "unfilled",
          prior_last_names: ""
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
        has_prior_last_names: "yes",
        prior_last_names: "Smith, Jones"
      }
    end

    it "saves the prior last names to the intake" do
      form = described_class.new(intake, valid_params)
      expect(form).to be_valid
      expect do
        form.save
      end.to change { intake.reload.prior_last_names }.to("Smith, Jones")
    end
  end

  describe "no prior last names to save" do
    let(:intake) { create :state_file_az_intake }
    let(:valid_params) do
      {
        has_prior_last_names: "no",
        prior_last_names: ""
      }
    end

    it "proceeds with nil prior last names" do
      form = described_class.new(intake, valid_params)
      expect(form).to be_valid
      form.save
      expect(intake.reload.prior_last_names).to be_nil
    end
  end

  describe "going back and removing prior last names" do
    let(:intake) { create :state_file_az_intake, prior_last_names: "Jordan, Pippin" }
    let(:valid_params) do
      {
        has_prior_last_names: "no",
        prior_last_names: "Jordan, Pippin"
      }
    end

    it "proceeds with nil prior last names" do
      form = described_class.new(intake, valid_params)
      expect(form).to be_valid
      expect do
        form.save
      end.to change { intake.reload.prior_last_names }.to(nil)
    end
  end
end
