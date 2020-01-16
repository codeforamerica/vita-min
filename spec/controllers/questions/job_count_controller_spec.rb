require "rails_helper"

RSpec.describe Questions::JobCountController do
  describe "#edit" do
    context "when there is no intake" do
      it "renders edit and returns 200" do
        get :edit

        expect(response).to be_ok
      end
    end
  end

  describe "#update" do
    context "when there is no intake" do
      it "creates a new intake and stores it to the session" do
        ## Delete this spec when we have more controllers in front of this one.
        expect {
          post :update, params: { form: { job_count: "3" } }
        }.to change(Intake, :count).by(1)

        intake = Intake.last

        expect(session[:intake_id]).to eq intake.id
      end
    end
  end
end

