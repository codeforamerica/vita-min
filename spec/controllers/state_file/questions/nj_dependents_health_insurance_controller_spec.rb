require 'rails_helper'

RSpec.describe StateFile::Questions::NjDependentsHealthInsuranceController do
  describe ".show?" do
    context "when intake has no dependents" do
      let(:intake) { create :state_file_nj_intake}
      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when intake has depedents" do
      let(:intake) { create :state_file_nj_intake, :df_data_two_deps }
      
      context "and did not have a health insurance requirement exception and all members had health insurance" do
        it "does not show" do
          allow_any_instance_of(StateFileNjIntake).to receive(:has_health_insurance_requirement_exception?).and_return(false)
          allow_any_instance_of(StateFileNjIntake).to receive(:eligibility_all_members_health_insurance_no?).and_return(false)
          expect(described_class.show?(intake)).to eq false
        end
      end
  
      context "and had a health insurance requirement exception, and all members had health insurance" do
        it "shows" do
          allow_any_instance_of(StateFileNjIntake).to receive(:has_health_insurance_requirement_exception?).and_return(true)
          allow_any_instance_of(StateFileNjIntake).to receive(:eligibility_all_members_health_insurance_no?).and_return(false)
          expect(described_class.show?(intake)).to eq true
        end
      end
     
      context "and did not have a health insurance requirement exception, but all members did not have health insurance" do  
        it "shows" do
          allow_any_instance_of(StateFileNjIntake).to receive(:has_health_insurance_requirement_exception?).and_return(false)
          allow_any_instance_of(StateFileNjIntake).to receive(:eligibility_all_members_health_insurance_no?).and_return(true)
          expect(described_class.show?(intake)).to eq true
        end
      end
    end
  end

  describe "#update" do
    context "taxpayer with dependents" do
      let(:intake) { create :state_file_nj_intake, :df_data_two_deps }
      let(:first_dependent) { intake.dependents[0] }
      let(:second_dependent) { intake.dependents[1] }

      let(:form_params) do
        {
          state_file_nj_eligibility_health_insurance_form: {
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
        }
      end

      before do
        sign_in intake
      end

      render_views
      it "succeeds" do
        get :edit
        expect(response).to be_successful
      end

      it "shows all dependents" do
        get :edit
        expect(response.body).to include("Aphrodite")
        expect(response.body).to include("Kronos")
      end

      it "saves the checkbox selections" do
        post :update, params: form_params
        intake.reload
        expect(intake.dependents[0].nj_did_not_have_health_insurance).to eq "yes"
        expect(intake.dependents[1].nj_did_not_have_health_insurance).to eq "no"
      end
    end


    context "when taxpayer with dependents affirms coverage when answer was previously no and they had indicated dependents without coverage" do
      let(:intake) { create :state_file_nj_intake, :df_data_two_deps, eligibility_all_members_health_insurance: 'no' }
      let(:first_dependent) { intake.dependents[0] }
      let(:second_dependent) { intake.dependents[1] }

      let(:form_params) do
        {
          state_file_nj_eligibility_health_insurance_form: {
            eligibility_all_members_health_insurance: "yes",
            dependents_attributes: {
              '0': {
                id: first_dependent.id,
                nj_did_not_have_health_insurance: 'yes'
              },
              '1': {
                id: second_dependent.id,
                nj_did_not_have_health_insurance: 'yes'
              }
            }
          }
        }
      end

      before do
        sign_in intake
      end
      
      it "sets all dependent values to no to indicate that they did indeed have coverage" do
        first_dependent.nj_did_not_have_health_insurance = 'no'
        second_dependent.nj_did_not_have_health_insurance = 'yes'
        intake.reload
        post :update, params: form_params
        intake.reload
        expect(intake.dependents[0].nj_did_not_have_health_insurance).to eq "no"
        expect(intake.dependents[1].nj_did_not_have_health_insurance).to eq "no"
      end
    end
  end
end