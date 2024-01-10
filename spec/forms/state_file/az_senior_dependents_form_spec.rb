require "rails_helper"

RSpec.describe StateFile::AzSeniorDependentsForm do
  describe "#valid?" do
    let(:intake) { create :state_file_az_intake }
    let!(:first_dependent) { create(:state_file_dependent, intake: intake) }
    let!(:second_dependent) { create(:az_senior_dependent_missing_intake_answers, intake: intake) }

    context "with invalid params" do
      let(:invalid_params) do
        {
          dependents_attributes: {
            "0": {
              id: second_dependent.id
            }
          }
        }
      end

      it "returns false" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
        expect(form.dependents.first.valid?(:az_senior_form)).to eq false
        expect(form.dependents.first.errors).to include :needed_assistance
        expect(form.dependents.first.errors).to include :passed_away
      end
    end
  end

  describe "#save" do
    context "when all dependents are over 65 and are parents/grandparents and lived with the filer for 12 months" do
      let(:intake) { create :state_file_az_intake }
      let!(:first_dependent) { create(:az_senior_dependent, intake: intake) }
      let!(:second_dependent) { create(:az_senior_dependent, intake: intake) }

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
      let(:intake) { create :state_file_az_intake }
      let!(:first_dependent) { create(:state_file_dependent, intake: intake) }
      let!(:second_dependent) { create(:az_senior_dependent, intake: intake) }

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
