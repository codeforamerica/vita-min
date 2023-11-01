require "rails_helper"

RSpec.describe StateFile::AzSeniorDependentsForm do
  let(:intake) { create :state_file_az_intake, dependents: [create(:state_file_dependent, dob: Date.parse("August 24, 2015")), create(:state_file_dependent, dob: Date.parse("August 24, 1944"))] }
  let(:first_dependent) { intake.dependents.first }
  let(:second_dependent) { intake.dependents.second }

  describe "#valid?" do
    context "with invalid params" do
      let(:invalid_params) do
        {
          dependents_attributes: {
            "0": {
              id: second_dependent.id,
              needed_assistance: "unfilled",
              passed_away: "unfilled"
            }
          }
        }
      end

      it "returns false" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
      end
    end
  end

  describe "#save" do
    context "when all dependents are over 65 and are parents/grandparents and lived with the filer for 12 months" do
      let(:intake) { create :state_file_az_intake, dependents: [create(:state_file_dependent, dob: Date.parse("August 24, 1952"), relationship: "PARENT", months_in_home: 12), create(:state_file_dependent, dob: Date.parse("August 24, 1944"), relationship: "PARENT", months_in_home: 12)] }

      context "with valid params" do
        let(:valid_params) do
          {
            dependents_attributes: {
              "0": {
                id: first_dependent.id,
                needed_assistance: "yes",
                passed_away: "no"
              },
              "1": {
                id: second_dependent.id,
                needed_assistance: "no",
                passed_away: "yes"
              }
            }
          }
        end

        it "saves senior dependent fields" do
          form = described_class.new(intake, valid_params)
          expect(form).to be_valid
          form.save

          expect(first_dependent.reload.needed_assistance_yes?).to be true
          expect(first_dependent.reload.passed_away_yes?).to be false

          expect(second_dependent.reload.needed_assistance_yes?).to be false
          expect(second_dependent.reload.passed_away_yes?).to be true
        end
      end
    end

    context "when only one dependent is over 65 and are parents/grandparents and lived with the filer for 12 months" do
      let(:intake) { create :state_file_az_intake, dependents: [create(:state_file_dependent, dob: Date.parse("August 24, 1984")), create(:state_file_dependent, dob: Date.parse("August 24, 1944"))] }

      context "with valid params" do
        let(:valid_params) do
          {
            dependents_attributes: {
              "0": {
                id: second_dependent.id,
                needed_assistance: "yes",
                passed_away: "no"
              }
            }
          }
        end

        it "saves only senior dependent fields" do
          form = described_class.new(intake, valid_params)
          expect(form).to be_valid
          form.save

          expect(first_dependent.reload.needed_assistance_unfilled?).to be true
          expect(first_dependent.reload.passed_away_unfilled?).to be true

          expect(second_dependent.reload.needed_assistance_yes?).to be true
          expect(second_dependent.reload.passed_away_yes?).to be false
        end
      end
    end
  end
end
