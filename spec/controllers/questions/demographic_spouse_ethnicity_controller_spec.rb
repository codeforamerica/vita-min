require "rails_helper"

RSpec.describe Questions::DemographicSpouseEthnicityController do
  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          demographic_spouse_ethnicity_form: {
            demographic_spouse_ethnicity: "hispanic_latino",
          }
        }
      end
      let(:intake) { create(:intake, demographic_questions_opt_in: "yes", filing_joint: "yes") }

      before do
        sign_in intake.client
      end

      it "logs you out" do
        post :update, params: params
        expect(response).to redirect_to(root_path)
        expect(subject.current_client).to eq(nil)
      end
    end
  end
end
