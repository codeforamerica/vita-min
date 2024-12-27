require 'rails_helper'

RSpec.describe StateFile::NjDependentsHealthInsuranceForm do
  let(:intake) {
    create :state_file_nj_intake,
    :df_data_two_deps
  }
  let(:first_dependent) { intake.dependents[0] }
  let(:second_dependent) { intake.dependents[1] }

  describe "#save" do
    context "when not all tax household members had health insurance" do
      let(:valid_params) do
        {
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
        expect(intake.dependents[0].nj_did_not_have_health_insurance).to eq "yes"
        expect(intake.dependents[1].nj_did_not_have_health_insurance).to eq "no"
      end
    end
  end
end