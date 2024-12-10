require 'rails_helper'

RSpec.describe StateFile::NjEligibilityHealthInsuranceForm do
  let(:intake) {
    create :state_file_nj_intake,
    :df_data_two_deps,
    eligibility_all_members_health_insurance: "unfilled"
  }
  let(:first_dependent) { intake.dependents[0] }
  let(:second_dependent) { intake.dependents[1] }

  describe "validations" do
    let(:invalid_params) do
      { eligibility_all_members_health_insurance: nil }
    end

    it "requires radio answer" do
      form = described_class.new(intake, invalid_params)
      form.valid?

      expect(form.errors[:eligibility_all_members_health_insurance]).to include "Can't be blank."
    end

    # TODO: add validations that *someone* is checked if we add a box for other/self/spouse
  end

  describe "#save" do
    context "when all tax household members had health insurance" do
      let(:valid_params) do
        {
          eligibility_all_members_health_insurance: "yes",
          dependents_attributes: {
            '0': {
              id: first_dependent.id,
              nj_did_not_have_health_insurance: 'yes'
            },
            '1': {
              id: second_dependent.id,
              nj_did_not_have_health_insurance: 'no'
            }
          }
        }
      end
      
      it "saves the yes for all members to the intake" do
        form = described_class.new(intake, valid_params)
        form.save
        intake.reload
        expect(intake.eligibility_all_members_health_insurance_yes?).to eq true
      end

      it "does not save entered data for specific dependents" do
        form = described_class.new(intake, valid_params)
        form.save
        intake.reload
        expect(intake.dependents[0].nj_did_not_have_health_insurance).to eq "unfilled"
        expect(intake.dependents[1].nj_did_not_have_health_insurance).to eq "unfilled"
      end
    end

    context "when not all tax household members had health insurance" do
      let(:valid_params) do
        {
          eligibility_all_members_health_insurance: "no",
          dependents_attributes: {
            '0': {
              id: first_dependent.id,
              nj_did_not_have_health_insurance: 'yes'
            },
            '1': {
              id: second_dependent.id,
              nj_did_not_have_health_insurance: 'no'
            }
          }
        }
      end
      
      it "saves the answers to the intake" do
        form = described_class.new(intake, valid_params)
        form.save
        intake.reload
        expect(intake.eligibility_all_members_health_insurance_yes?).to eq false
        expect(intake.dependents[0].nj_did_not_have_health_insurance).to eq "yes"
        expect(intake.dependents[1].nj_did_not_have_health_insurance).to eq "no"
      end
    end
  end
end