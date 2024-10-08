require 'rails_helper'

RSpec.describe StateFile::NcEligibilityResidenceForm do
  let(:intake) { create :state_file_nc_intake, eligibility_lived_in_state: "unfilled" }

  describe "validations" do
    let(:invalid_params) { { eligibility_lived_in_state: nil } }

    it "requires both params" do
      form = described_class.new(intake, invalid_params)
      form.valid?

      expect(form.errors[:eligibility_lived_in_state]).to include "Can't be blank."
    end
  end

  describe "#save" do
    let(:valid_params) { { eligibility_lived_in_state: "yes" } }

    it "saves the answers to the intake" do
      form = described_class.new(intake, valid_params)
      form.save
      intake.reload
      expect(intake.eligibility_lived_in_state_yes?).to eq true
    end
  end
end