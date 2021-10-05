require "rails_helper"

RSpec.describe Questions::DemographicQuestionsController do
  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          demographic_questions_form: {
            demographic_questions_opt_in: answer,
          }
        }
      end
      let(:intake) { create(:intake, demographic_questions_opt_in: "yes", filing_joint: "yes") }
      let(:answer) { "yes" }

      before do
        sign_in intake.client
      end

      describe "answering 'yes'" do
        let(:answer) { 'yes' }

        it 'persists the value' do
          post :update, params: params
          expect(intake.reload.demographic_questions_opt_in).to eq("yes")
          expect(subject.current_client).not_to be_nil
        end
      end

      describe "answering 'no'" do
        let(:answer) { "no" }

        it "persists the value and logs you out" do
          post :update, params: params
          expect(intake.reload.demographic_questions_opt_in).to eq("no")
          expect(response).to redirect_to(root_path)
          expect(subject.current_client).to eq(nil)
        end
      end
    end
  end
end
