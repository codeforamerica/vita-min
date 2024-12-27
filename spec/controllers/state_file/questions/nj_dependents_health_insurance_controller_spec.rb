require 'rails_helper'

RSpec.describe StateFile::Questions::NjDependentsHealthInsuranceController do
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