require "rails_helper"

RSpec.describe Questions::WagesController do
  describe "#edit" do
    context "when there is an intake" do
      let!(:intake) { create :intake }

      before do
        session[:intake_id] = intake.id
      end

      it "renders edit and returns 200" do
        get :edit

        expect(response).to be_ok
      end
    end

    context "when there is no intake" do
      # include once this controller is no longer the first
      xit "redirects to root path" do
        get :edit

        expect(response).to redirect_to(root_path)
      end

      it "renders edit and returns 200" do
        get :edit

        expect(response).to be_ok
      end
    end
  end

  describe "#update" do
    context "when there is an intake" do
      let!(:intake) { create :intake }

      before do
        session[:intake_id] = intake.id
      end

      it "updates has_wages on the current intake and returns a redirect" do
        post :update, params: { form: { has_wages: "yes" } }

        intake.reload
        expect(intake.has_wages).to eq "yes"
        expect(response.status).to eq 302
      end
    end

    context "when there is no intake" do
      it "creates a new intake and stores it to the session" do
        ## Delete this spec when we have more controllers in front of this one.
        expect {
          post :update, params: { form: { has_wages: "yes" } }
        }.to change(Intake, :count).by(1)

        intake = Intake.last

        expect(session[:intake_id]).to eq intake.id
      end
    end
  end
end
