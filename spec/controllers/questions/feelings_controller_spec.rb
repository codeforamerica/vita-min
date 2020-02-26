require "rails_helper"

RSpec.describe Questions::FeelingsController do
  describe "#update" do
    let(:feeling) { "neutral" }
    let(:params) { { feelings_form: { feeling_about_taxes: feeling } } }

    before do
      session[:source] = "source_from_session"
      session[:referrer] = "referrer_from_session"
    end

    RSpec.shared_examples "feelings survey" do
      describe "feelings" do
        it "creates a new intake with the survey answer and saves id in the session" do
          expect {
            post :update, params: params
          }.to change(Intake, :count).by(1)

          intake = Intake.last
          expect(intake.source).to eq "source_from_session"
          expect(intake.referrer).to eq "referrer_from_session"
          expect(intake.feeling_about_taxes).to eq feeling
          expect(session[:intake_id]).to eq intake.id
          expect(response).to redirect_to(eligibility_questions_path)
        end
      end
    end

    it_behaves_like "feelings survey" do
      let(:feeling) { "positive" }
    end

    it_behaves_like "feelings survey" do
      let(:feeling) { "neutral" }
    end

    it_behaves_like "feelings survey" do
      let(:feeling) { "negative" }
    end
  end
end

