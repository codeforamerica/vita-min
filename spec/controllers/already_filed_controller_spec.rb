require "rails_helper"

RSpec.describe Questions::AlreadyFiledController do
  render_views

  describe "#update" do
    before do
      session[:source] = "source_from_session"
      session[:referrer] = "referrer_from_session"
    end

    context "with valid params" do
      let(:params) do
        {
          already_filed_form: {
            already_filed: "yes",
          }
        }
      end

      it "creates new intake with the already filed answer" do
        expect {
          post :update, params: params
        }.to change(Intake, :count).by(1)

        intake = Intake.last
        expect(intake.source).to eq "source_from_session"
        expect(intake.referrer).to eq "referrer_from_session"
        expect(intake.already_filed).to eq "yes"
        expect(session[:intake_id]).to eq intake.id
      end
    end
  end
end
