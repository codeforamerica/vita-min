require "rails_helper"

RSpec.describe Questions::DemographicPrimaryEthnicityController do
  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          demographic_primary_ethnicity_form: {
            demographic_primary_ethnicity: "hispanic_latino",
          }
        }
      end
      let(:intake) { create(:intake, demographic_questions_opt_in: "yes", filing_joint: filing_joint) }

      before do
        sign_in intake.client
      end

      context "when filing joint" do
        let(:filing_joint) { "yes" }

        it "sends you to the spouse ethnicity controller" do
          post :update, params: params
          expect(response).to redirect_to(Questions::DemographicSpouseEthnicityController.to_path_helper)
        end
      end

      context "when not filing joint" do
        let(:filing_joint) { "no" }

        it "sends you to the homepage and logs you out" do
          post :update, params: params
          expect(response).to redirect_to(root_path)
          expect(subject.current_client).to eq(nil)
        end
      end
    end
  end

  describe 'next_path' do
    let(:intake) { create :intake, demographic_questions_opt_in: "yes", filing_joint: filing_joint }

    before { sign_in intake.client }
    context "when not filing joint" do
      let(:filing_joint) { "no" }
      it "goes to home page" do
        expect(subject.next_path).to eq(root_path)
      end
    end

    context "when filing joint" do
      let(:filing_joint) { "yes" }

      it "goes to spouse ethnicity controller" do
        expect(subject.next_path).to eq(Questions::DemographicSpouseEthnicityController.to_path_helper)
      end
    end
  end
end